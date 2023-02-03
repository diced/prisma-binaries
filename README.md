# Prisma Binaries

Prisma Binaries for arm64 and amd64 architectures, that use Alpine Docker images.

## Why?
Prisma does not provide binaries that work for these architectures on Alpine linux, therefore we have to build our own! How fun.

## Building
You can't build these images using docker buildx's `--platform linux/arm64,linux/amd64` for some reason, it fails compiling, and will take a very long time to build due to it emulating the arm64, or amd64 architecture. So we have to build them separately, on seperate machines, which we will combine into a multi-arch image.

```bash
docker build -t prisma-binaries:{version}-{amd64/arm64} --build-arg PRISMA_VERSION={version} .
# Example
docker build -t prisma-binaries:4.9.x-amd64 --build-arg PRISMA_VERSION=4.9.0 . # on amd64 machine
docker build -t prisma-binaries:4.9.x-arm64 --build-arg PRISMA_VERSION=4.9.0 . # on arm64 machine
```

## Combining images
Retrieve each image somehow, so they are on one machine then follow the steps below.

```bash
docker manifest create prisma-binaries:{version} --amend prisma-binaries:{version}-amd64 --amend prisma-binaries:{version}-arm64
docker manifest push prisma-binaries:{version}
```

Example:
```bash
docker manifest create prisma-binaries:4.9.x --amend prisma-binaries:4.9.x-amd64 --amend prisma-binaries:4.9.x-arm64
docker manifest push prisma-binaries:4.9.x
```

You do not need to push if you will be using the image locally. 

## Using
You can use this image in your Dockerfile like so:

```Dockerfile
FROM prisma-binaries:4.9.x as prisma

# In stages that require prisma binaries copy them over.
COPY --from=prisma /prisma-engines /prisma-engines
ENV PRISMA_QUERY_ENGINE_BINARY=/prisma-engines/query-engine \
  PRISMA_MIGRATION_ENGINE_BINARY=/prisma-engines/migration-engine \
  PRISMA_INTROSPECTION_ENGINE_BINARY=/prisma-engines/introspection-engine \
  PRISMA_FMT_BINARY=/prisma-engines/prisma-fmt \
  PRISMA_CLI_QUERY_ENGINE_TYPE=binary \
  PRISMA_CLIENT_ENGINE_TYPE=binary
```

A real-world example is found in [Zipline's Dockerfile](https://github.com/diced/zipline/blob/trunk/Dockerfile)