
#include <glib.h>
#include <glib/gthread.h>

// used to generate new taxon ids and GIs for those refseqs that lack them
#define FIRST_UNKNOWN_TAXON_ID -100
#define FIRST_UNKNOWN_GI -100

// print progress message after reading this many rows from any big input file
#define PROGRESS_INTERVAL_ROWS 100000

GHashTable *build_refseq_hash(bam_header_t *bam_header, int **refseq_gids, gboolean verbose);
GHashTable *read_gi_to_taxon_map(char *input_map_file, char *output_map_file, bam_header_t *bam_header, GHashTable *refseq_gi_ht, int *target_gids, gboolean verbose);
