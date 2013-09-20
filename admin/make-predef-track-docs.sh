#!/bin/tcsh

# uncomment these lines to force all figures to be regenerated (regardless of whether config files have changed)
#rm ../html/docs/predefined-tracks/*.svg
#rm ../html/docs/predefined-tracks/*.png
#rm ../html/docs/predefined-tracks/*.pdf

# regenerate predefined track documentation page(s)
./makePredefTrackDocs.pl ../conf/predefined-tracks.cfg ../html/docs .. ../data/CM000961.gbk >../html/docs/predefined-tracks.html
