#!/bin/tcsh
setenv BIN_DIR /usr/local/bin
setenv DATA_DIR data
setenv CONF_DIR conf

$BIN_DIR/circleator \
--data=data/CP002725.1.gb \
--config=conf/Gv_HMP9231.cfg \
--debug=all \
--log=Gv_HMP9231.log \
>Gv_HMP9231.svg 

# rasterize entire image
$BIN_DIR/rasterize-svg Gv_HMP9231.svg png 5000 5000
mv Gv_HMP9231.png Gv_HMP9231-full.png

# rasterize inset image (full SVG image size is 3200x3200)
$BIN_DIR/rasterizer -a '1000,250,1200,1200' -bg '255.255.255.255' -w 1000 -h 1000 -m 'image/png' Gv_HMP9231.svg
mv Gv_HMP9231.png Gv_HMP9231-inset.png

# generate inset overlay
$BIN_DIR/rasterize-svg overlay.svg png 10000 5000
$BIN_DIR/rasterize-svg overlay.svg png 2000 1000
