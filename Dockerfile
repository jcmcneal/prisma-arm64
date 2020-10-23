FROM rust:latest as prisma-build

RUN apt-get update && apt-get install direnv

RUN git clone https://github.com/prisma/prisma-engines.git

WORKDIR /prisma-engines

RUN direnv allow
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
