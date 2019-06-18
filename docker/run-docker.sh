#!/bin/bash
docker run -dt --name 'c1' umigs/circleator:latest
docker exec -i -t c1 /bin/bash
