VERSION=1.18.0

DOCKER_CLI_EXPERIMENTAL=enabled docker buildx create --name mybuilder
DOCKER_CLI_EXPERIMENTAL=enabled docker buildx use mybuilder

DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --push --platform linux/amd64 --tag distroless/distroless-nginx:$VERSION .
DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --push --platform linux/amd64 --tag distroless/distroless-nginx:latest .
