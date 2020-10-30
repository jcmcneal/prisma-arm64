FROM rust:latest as prisma-build

RUN cat /etc/*release

RUN apt-get update
RUN apt-get install -y direnv openssl
# RUN apt-get install -qy gcc-aarch64-linux-gnu

RUN git clone https://github.com/prisma/prisma-engines.git

WORKDIR /prisma-engines

RUN direnv allow

# RUN rustup target add aarch64-unknown-linux-gnu
# RUN rustup toolchain install stable-aarch64-unknown-linux-gnu

# ENV OPENSSL_INCLUDE_DIR=/usr/include/openssl
# ENV OPENSSL_LIB_DIR=/usr/lib/ssl
# RUN cargo build --release --target aarch64-unknown-linux-gnu
RUN cargo build --release

FROM node:14.13.1-buster as builder

COPY --from=prisma-build /prisma-engines/target/release/query-engine /prisma-arm/query-engine
COPY --from=prisma-build /prisma-engines/target/release/migration-engine /prisma-arm/migration-engine
COPY --from=prisma-build /prisma-engines/target/release/introspection-engine /prisma-arm/introspection-engine
COPY --from=prisma-build /prisma-engines/target/release/prisma-fmt /prisma-arm/prisma-fmt

COPY .env /prisma-arm/.env

RUN chmod +x /prisma-arm/*

RUN ls -la /prisma-arm

CMD tail -f /dev/null
