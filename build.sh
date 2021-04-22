VERSION=1.18.0

docker run --rm --privileged docker/binfmt:820fdd95a9972a5308930a2bdfb8573dd4447ad3
DOCKER_CLI_EXPERIMENTAL=enabled docker buildx create --name mybuilder --use


DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --push --platform linux/arm/v7,linux/arm64/v8,linux/amd64 --tag distroless/distroless-nginx:$VERSION .