#!/bin/bash
docker run -dt --name 'c1' umigs/circleator-v1.0.2:latest
docker exec -i -t c1 /bin/bash
