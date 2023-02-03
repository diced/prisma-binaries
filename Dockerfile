FROM rust:1.64.0-alpine3.16 as prisma

ENV RUSTFLAGS="-C target-feature=-crt-static"
ARG PRISMA_VERSION

RUN apk --no-cache --virtual .build-deps add openssl direnv git musl-dev openssl-dev build-base perl protoc rustup
RUN git clone --depth=1 --branch=${PRISMA_VERSION} https://github.com/prisma/prisma-engines.git /prisma && cd /prisma

WORKDIR /prisma

RUN cargo build --release

RUN apk del .build-deps

FROM alpine:3.16
COPY --from=prisma /prisma/target/release/query-engine /prisma/target/release/migration-engine /prisma/target/release/introspection-engine /prisma/target/release/prisma-fmt /prisma-engines/
