#!/bin/bash

docker buildx build -f armv5.Dockerfile --platform linux/arm/v5 -t n5ray/amneziawg-mikrotik-armv5:debian-slim-armv5 .
docker push n5ray/amneziawg-mikrotik-armv5:debian-slim-armv5
