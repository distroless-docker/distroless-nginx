# Description
This repository builds docker from debian/ubuntu sources into a scratch container

# Build

## Build Single Arch
docker build -t distroless-nginx  .

## Build Multi Arch
docker buildx build --push --platform linux/arm/v7,linux/arm64/v8,linux/amd64 --tag distrolessdocker/distroless-nginx  .

# Usage
docker run -p  80:80 distrolessdocker/distroless-nginx:1.18.0 

# Licenses

This image itself is published under the CC0 license.

 However, this image contains other software which may be under other licenses (such as nginx, SSL or other dependencies). Some licenses are automatically collected and exported to /licenses within the container. It is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

All source packages of the packages contained in this image are pushed in the -sources container.