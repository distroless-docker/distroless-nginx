VERSION=1.18.0

DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --push --platform linux/arm/v7,linux/arm64/v8,linux/amd64 --tag $DOCKERHUB:$VERSION .
DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --push --platform linux/arm/v7,linux/arm64/v8,linux/amd64 --tag $DOCKERHUB:latest .
