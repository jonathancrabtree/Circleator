#!/bin/tcsh

circleator --config=fig-1.txt --data=../gb_annotation/L42023.1.gb --debug=all > fig-1.svg
rasterize-svg fig-1.svg png 3000

