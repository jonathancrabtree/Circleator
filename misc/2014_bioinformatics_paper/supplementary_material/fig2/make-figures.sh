#!/bin/tcsh
setenv BIN_DIR /usr/local/bin
setenv DATA_DIR data
setenv CONF_DIR conf

$BIN_DIR/circleator \
 --data=${DATA_DIR}/NC_003361.3.gbk \
 --config=./conf/Cc_GPIC_BSR.cfg \
 --log=Cc_GPIC_BSR.log \
 --debug=all \
> Cc_GPIC_BSR.svg

$BIN_DIR/rasterize-svg Cc_GPIC_BSR.svg png 5000 5000
