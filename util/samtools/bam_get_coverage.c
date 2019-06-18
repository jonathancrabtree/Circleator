#include <stdio.h>
#include <inttypes.h>
#include "sam.h"
#include "bam_hmp_util.h"

// ---------------------------------------------------------------------------------
// Extract coverage information from a BAM file for all sequences from a specified
// list of taxon_ids.  The coverage data will be extracted into a set of flat files 
// compatible with Circleator::SeqFunction::FlatFile
//
// jonathancrabtree@gmail.com
// ---------------------------------------------------------------------------------

// TODO - generalize this to output either summarized coverage info. _or_ detailed read information
int dummy_val = 1;

void _foreach_tid_add_to_hash(gpointer value, gpointer user_data) {
  int *taxon_id = (int *)value;
  GHashTable *ht = (GHashTable *)user_data;
  g_hash_table_insert(ht, taxon_id, &dummy_val);
}

typedef struct _Coverage_Helper
{
  bam_header_t *bam_header;
  int target_ind;
  long n_alignments;
  bam_plbuf_t *pileup_buf;
  long coverage_sum;
  long window_size;
  long next_window_end_pos;
  GHashTable *output_file_ht;
  GIOChannel *ofh;
  gboolean count_deleted_bases;
} Coverage_Helper;

// coverage-calculating callback for bam_fetch
int _bam_fetch_func(const bam1_t *b, void *data) {
  Coverage_Helper *ch = (Coverage_Helper *)data;
  ++ch->n_alignments;
  // add alignment to the current pileup buffer
  bam_plbuf_push(b, ch->pileup_buf);
  return 0;
}

// pileup function; note that this only gets called for positions where n >= 1 (in samtools-0.1.12a)
int _bam_pileup_func(uint32_t tid, uint32_t pos, int n, const bam_pileup1_t *pl, void *data) {
  Coverage_Helper *ch = (Coverage_Helper *)data;

  if (tid != ch->target_ind) {
    fprintf(stderr, "FATAL - _bam_pileup_func called with tid=%d, expected %d\n", tid, ch->target_ind);
    exit(1);
  }
  
  // see whether an update needs to be printed
  if (pos >= ch->next_window_end_pos) {
    gsize bytecount = -1;

    // output extra empty windows as needed (although the first one may not be empty)
    long num_empty = (long)((pos - ch->next_window_end_pos) / (float)ch->window_size);
    long i;
  
    for (i = 0;i < num_empty; ++i) {
      GString *line = g_string_new("");
      g_string_append_printf(line, "%s\t%ld\t%ld\t%f\n", ch->bam_header->target_name[tid], ch->next_window_end_pos - ch->window_size, ch->next_window_end_pos, ((float)ch->coverage_sum)/ch->window_size);
      GIOStatus ws = g_io_channel_write_chars(ch->ofh, line->str, -1, &bytecount, NULL);
      g_string_free(line, TRUE);
      if (ws != G_IO_STATUS_NORMAL) {
        fprintf(stderr, "FATAL - couldn't write to the output file for taxon_id %d\n", tid);
        return 1;
      }
      ch->coverage_sum = 0;
      ch->next_window_end_pos += ch->window_size;
    }

    GString *line = g_string_new("");
    g_string_append_printf(line, "%s\t%ld\t%ld\t%f\n", ch->bam_header->target_name[tid], ch->next_window_end_pos - ch->window_size, ch->next_window_end_pos, ((float)ch->coverage_sum)/ch->window_size);
    GIOStatus ws = g_io_channel_write_chars(ch->ofh, line->str, -1, &bytecount, NULL);
    g_string_free(line, TRUE);
    if (ws != G_IO_STATUS_NORMAL) {
      fprintf(stderr, "FATAL - couldn't write to the output file for taxon_id %d\n", tid);
      return 1;
    }
    ch->coverage_sum = 0;
    ch->next_window_end_pos += ch->window_size;
  }

  if (ch->count_deleted_bases) {
    ch->coverage_sum += n;
    //    fprintf(stderr, "adding %d to coverage sum, now total=%d\n", n, ch->coverage_sum);
  } 
  else {
    long num_dels = 0;
    long p = 0;

    for (p = 0;p < n;++p) {
      bam_pileup1_t pup = pl[p];
      if (pup.is_del) { ++num_dels; }
      //    fprintf(stderr, "pos=%d p=%d qpos=%d is_del=%d is_head=%d is_tail=%d\n", pos, p, pup.qpos, pup.is_del, pup.is_head, pup.is_tail);
      // DEBUG
      //if (pup.indel != 0) {
      //      fprintf(stderr, "*** position p=%d, indel=%d, level=%d\n", p, pup.indel, pup.level);
      //      exit;
      //}
    }
    ch->coverage_sum += (n - num_dels);
    //    fprintf(stderr, "adding %d to coverage sum, minus %d dels\n", n, num_dels);
  } 
  return 0;
}

void _foreach_io_channel_close(gpointer key, gpointer value, gpointer user_data) {
  int *taxid = (int *)key;
  GIOChannel *ofh = (GIOChannel *)value;
  g_io_channel_shutdown(ofh, TRUE, NULL);
}

// ---------------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------------

int main(int argc, char *argv[])
{
  // samtools objects for the SAM file and BAM header, respectively
  samfile_t *sam_file;
  bam_header_t *bam_header;
  int i;
  int window_size;
  gchar *bam_filename = NULL;
  gchar *output_path = NULL;
  gchar *seqid = NULL;
  int start;
  int end;

  int dummy_taxon_id = FIRST_UNKNOWN_TAXON_ID;

  // input/usage
  // taxid mapping is needed to group alignments by genome rather than sequence
  if ((argc != 9) && (argc != 6) && (argc != 4)) {
    fprintf(stderr, "Usage: bam_get_coverage <in.bam> <window_size> <output_path> [<gi_taxid_nucl.dmp> <taxid_list.txt> <seqid> <start> <end>] \n");
    fprintf(stderr, " in.bam - BAM file containing the reference sequence alignments\n");
    fprintf(stderr, " window_size - Nonoverlapping window size in bp\n");
    fprintf(stderr, " output_path - Either a directory (if taxon id lists are given) or a file.\n");
    fprintf(stderr, " gi_taxid_nucl.dmp - NCBI-provided file (or subset thereof) mapping NCBI nucleotide GI to NCBI taxon_id\n");
    fprintf(stderr, " taxid_list.txt - List of taxon_ids whose sequences should be included in the output\n");
    fprintf(stderr, " seqid - ID of a single specific sequence to output.  If specified then the previous two arguments are ignored.\n");
    fprintf(stderr, " start - 0-based start position in sequence seqid.\n");
    fprintf(stderr, " end- 0-based end position in sequence seqid.\n");
    return 1;
  }

  gboolean filter_by_taxon = (argc == 6);
  bam_filename = argv[1];
  output_path = argv[3];

  sscanf(argv[2], "%d", &window_size);
  if (window_size < 1) {
    fprintf(stderr, "illegal window size %d\n", window_size);
    return 1;
  }

  // mode in which coverage is printed only for a specific sequence range
  if (argc == 9) {
    seqid = argv[6];
    sscanf(argv[7], "%d", &start);
    sscanf(argv[8], "%d", &end);
    fprintf(stderr, "INFO - outputing coverage only for seq %s, location %d - %d\n", seqid, start, end);
  }

  // ---------------------------------------------------------------------------------  
  // step 1: read taxon_id list from taxid_list.txt into a GHashTable
  // ---------------------------------------------------------------------------------
  GHashTable *taxon_ids = NULL;

  if (filter_by_taxon) {
    taxon_ids = g_hash_table_new(g_int_hash, g_int_equal);
    fprintf(stderr, "INFO - reading taxon_ids from %s\n", argv[5]);
    GIOChannel *fh = g_io_channel_new_file(argv[5], "r", NULL);
    if (fh == NULL) {
      fprintf(stderr, "FATAL - failed to read taxon id list from %s\n", argv[5]);
      return 1;
    }

    // read ids into a list and then transfer it to the hash table
    GIOStatus rs;
    gchar *line;
    int linenum = 0;
    int *tid;
    GSList *tids = NULL;
    
    while (rs = g_io_channel_read_line(fh, &line, NULL, NULL, NULL)) {
      if ((line == NULL) || (rs != G_IO_STATUS_NORMAL)) break;
      ++linenum;
      tid = g_malloc(sizeof(int));
      sscanf(line, "%d", tid);
      tids = g_slist_prepend(tids, tid);
    }
    g_io_channel_shutdown(fh, TRUE, NULL);
    GSList *rev_tids = g_slist_reverse(tids);
    g_slist_foreach(rev_tids, &_foreach_tid_add_to_hash, taxon_ids);
    fprintf(stderr, "INFO - read %d taxon_ids from %s\n", g_hash_table_size(taxon_ids), argv[5]);
  }

  // ---------------------------------------------------------------------------------  
  // step 2: build hash from reference sequence GIs to BAM header target index
  // ---------------------------------------------------------------------------------
  // calling samopen will populate sam_file->header with the BAM header if applicable
  sam_file = samopen(bam_filename, "rb", 0);

  if (sam_file == 0) {
    fprintf(stderr, "FATAL - failed to open BAM file %s\n", bam_filename);
    return 1;
  }

  bam_header = sam_file->header;
  fprintf(stderr, "INFO - read header from BAM file %s: n_targets=%d\n", bam_filename, bam_header->n_targets);
  int *refseq_gids;
  GHashTable *refseq_gi_ht = build_refseq_hash(bam_header, &refseq_gids, FALSE);

  // ---------------------------------------------------------------------------------  
  // step 3: map refseq GIs to taxon_ids using NCBI GI -> taxon_id mapping file
  // ---------------------------------------------------------------------------------
  GHashTable *gi_to_tid_ht = NULL;
  if (filter_by_taxon) {
    gi_to_tid_ht = read_gi_to_taxon_map(argv[4], NULL, bam_header, refseq_gi_ht, refseq_gids, FALSE);
    if (gi_to_tid_ht == NULL) { return 1; }
  }

  // ---------------------------------------------------------------------------------  
  // step 4: loop over ref sequence list, processing those from the input taxa
  // ---------------------------------------------------------------------------------
  
  // TODO - this assumes that it's faster to do directed queries by reference sequence
  // rather than scanning the entire file (debatable since the plan is to select those
  // ref seqs with the most alignments...may need further investigation)
  int n_targets_found = 0;
  int n_targets_output = 0;
  Coverage_Helper *ch = g_malloc(sizeof(Coverage_Helper));
  ch->bam_header = bam_header;
  ch->n_alignments = 0;
  // hash mapping taxon_id to output file
  ch->output_file_ht = g_hash_table_new(g_int_hash, g_int_equal);

  // TODO - add option to not count the deleted bases (i.e., for visualizing RNA-Seq data with large gaps)
  //        this will entail ignoring those pileup positions with is_del=1
  ch->count_deleted_bases = TRUE;

  // open BAM index
  bam_index_t *bam_index;
  if ((bam_index = bam_index_load(bam_filename)) == 0) {
    fprintf(stderr, "FATAL - BAM index file for %s could not be read\n", bam_filename);
    return 1;
  }

  for (i = 0;i < bam_header->n_targets; ++i) {
    // print everything if !filter_by_taxon
    gboolean print_target = TRUE;
    int *taxon_id = &dummy_taxon_id;

    if (filter_by_taxon) {
      // GI -> taxon_id lookup
      int target_gid = refseq_gids[i];
      int *ptr = (int *)g_hash_table_lookup(gi_to_tid_ht, &target_gid);
      if (ptr == NULL) {
        fprintf(stderr, "FATAL - failed to find taxon_id for target=%d, gi=%d from '%s'\n", i, target_gid, bam_header->target_name[i]);
        return 1;
      } 
      taxon_id = ptr;

      // check whether target_gid is among those we're printing
      if (g_hash_table_lookup(taxon_ids, ptr) == NULL) {
        print_target = FALSE;
      }
    }

    // single sequence selected for printing
    if ((seqid != NULL) && (g_strcmp0(seqid, bam_header->target_name[i]))) {
      print_target = FALSE;
    }

    if (print_target) {
      ++n_targets_found;
      fprintf(stderr, "INFO - printing coverage for seq %d, name=%s, taxon_id=%d\n", i, bam_header->target_name[i], *taxon_id);

      // initialize pileup buffer
      bam_plbuf_t *pb = bam_plbuf_init(&_bam_pileup_func, ch);
      ch->pileup_buf = pb;
      ch->target_ind = i;
      ch->coverage_sum = 0;
      ch->n_alignments = 0;
      ch->window_size = window_size;
      ch->next_window_end_pos = window_size;

      // make sure there's an open filehandle
      // TODO - need dummy taxon_id for when !filter_by_taxon
      GIOChannel *ofh = (GIOChannel *)g_hash_table_lookup(ch->output_file_ht, taxon_id);
      if (ofh == NULL) {
        // build output filename and open file for writing
        GString *ofname = g_string_new(output_path);
        // in this case output_path is a directory name
        if (filter_by_taxon) {
          g_string_append_printf(ofname, "/%d-coverage.txt", *taxon_id);
        }
        fprintf(stderr, "INFO - opening %s for taxon_id %d\n", ofname->str, *taxon_id);
        ofh = g_io_channel_new_file(ofname->str, "w", NULL);
        g_hash_table_insert(ch->output_file_ht, taxon_id, ofh);
      }
      ch->ofh = ofh;
      
      // retrieve _all_ alignments for target i
      bam_fetch(sam_file->x.bam, bam_index, i, 0, bam_header->target_len[i], ch, &_bam_fetch_func);

      // let the pileup buffer know that there are no more alignments
      bam_plbuf_push(NULL, ch->pileup_buf);

      // output extra empty windows as needed 
      gsize bytecount = -1;
      if (bam_header->target_len[i] > ch->next_window_end_pos) {
        long num_empty = (long)((bam_header->target_len[i] - ch->next_window_end_pos) / (float)ch->window_size) + 1;
        long j;
        //        fprintf(stderr, "target len=%d next_window_end_pos=%d window_size=%d num_empty=%d\n", bam_header->target_len[i], ch->next_window_end_pos, ch->window_size, num_empty);
        for (j = 0;j < num_empty; ++j) {
          GString *line = g_string_new("");
          g_string_append_printf(line, "%s\t%ld\t%ld\t%f\n", ch->bam_header->target_name[i], ch->next_window_end_pos - ch->window_size, ch->next_window_end_pos, ((float)ch->coverage_sum)/ch->window_size);
          GIOStatus ws = g_io_channel_write_chars(ch->ofh, line->str, -1, &bytecount, NULL);
          g_string_free(line, TRUE);
          if (ws != G_IO_STATUS_NORMAL) {
            fprintf(stderr, "error writing to the output file for taxon_id %d\n", *taxon_id);
            return 1;
          }
          ch->coverage_sum = 0;
          ch->next_window_end_pos += ch->window_size;
        }
      }

      long last_window_end_pos = ch->next_window_end_pos - ch->window_size;
      if (last_window_end_pos < 0) {
        fprintf(stderr, "FATAL - internal error, last_window_end_pos=%ld\n", last_window_end_pos);
        return 1;
      }
      long actual_window_size = bam_header->target_len[i] - last_window_end_pos;
      GString *gstr = g_string_new("");
      if (actual_window_size > ch->window_size) {
        fprintf(stderr, "error - length of last window is %ld, which exceeds the preset window size of %ld\n", actual_window_size, ch->window_size);
        exit(1);
      }
      if (actual_window_size > 0) {
        g_string_append_printf(gstr, "%s\t%ld\t%u\t%f\n", ch->bam_header->target_name[i], last_window_end_pos, bam_header->target_len[i], ((float)ch->coverage_sum)/actual_window_size);
        GIOStatus ws = g_io_channel_write_chars(ch->ofh, gstr->str, -1, &bytecount, NULL);
        g_string_free(gstr, TRUE);
        if (ws != G_IO_STATUS_NORMAL) {
          fprintf(stderr, "error writing to the output file for taxon_id %d\n", *taxon_id);
          return 1;
        }
      }

      bam_plbuf_destroy(ch->pileup_buf);
      ch->pileup_buf = NULL;

      if (ch->n_alignments > 0) {
        ++n_targets_output;
        fprintf(stderr, "INFO - printed coverage for %ld alignment(s) from %u bp sequence\n", ch->n_alignments, bam_header->target_len[i]);
      }
    }
  }

  // close all open filehandles in ch->output_file_ht
  g_hash_table_foreach(ch->output_file_ht, &_foreach_io_channel_close, NULL);

  g_free(ch);
  if (filter_by_taxon) {
    fprintf(stderr, "INFO - printed coverage info for %d/%d reference sequences with alignments from %d input taxon_ids\n", n_targets_output, n_targets_found, g_hash_table_size(taxon_ids));
  }
  else {
    fprintf(stderr, "INFO - printed coverage info for %d/%d reference sequences\n", n_targets_output, n_targets_found);
  }
  samclose(sam_file);
  return 0;
}
