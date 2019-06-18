#!/bin/bash

docker build -t umigs/circleator:v1.0.2 .
docker tag umigs/circleator:v1.0.2 umigs/circleator:latest
