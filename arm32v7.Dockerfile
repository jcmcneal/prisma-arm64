FROM rust:latest as prisma-build

RUN apt-get update
RUN apt-get install -qq direnv \
    gcc-arm-linux-gnueabihf
RUN rustup target add armv7-unknown-linux-gnueabihf

# Step 3: Configure cargo for cross compilation
RUN mkdir -p ~/.cargo
RUN echo '[target.armv7-unknown-linux-gnueabihf]' >> ~/.cargo/config
RUN echo 'linker = "arm-linux-gnueabihf-gcc"' >> ~/.cargo/config

RUN git clone https://github.com/prisma/prisma-engines.git

WORKDIR /prisma-engines

RUN direnv allow
RUN cargo build --release --target=armv7-unknown-linux-gnueabihf

FROM node:14.13.1-buster as builder

COPY --from=prisma-build /prisma-engines/target/release/query-engine /prisma-arm/query-engine
COPY --from=prisma-build /prisma-engines/target/release/migration-engine /prisma-arm/migration-engine
COPY --from=prisma-build /prisma-engines/target/release/introspection-engine /prisma-arm/introspection-engine
COPY --from=prisma-build /prisma-engines/target/release/prisma-fmt /prisma-arm/prisma-fmt

COPY .env /prisma-arm/.env

RUN chmod +x /prisma-arm/*

RUN ls -la /prisma-arm

CMD tail -f /dev/null
