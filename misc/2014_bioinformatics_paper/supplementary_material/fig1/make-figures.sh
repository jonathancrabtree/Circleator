#!/bin/tcsh
setenv BIN_DIR /usr/local/bin
setenv DATA_DIR data
setenv CONF_DIR conf

$BIN_DIR/circleator \
 --data=$DATA_DIR/L42023.1.gb \
 --config=$CONF_DIR/Hi_RdKW20.cfg \
 --log=make-figures.log \
 --debug=all \
> Hi_RdKW20.svg

$BIN_DIR/rasterize-svg Hi_RdKW20.svg png 5000 5000
