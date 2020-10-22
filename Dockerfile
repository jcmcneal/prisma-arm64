FROM rust:latest as prisma-build

RUN curl http://launchpadlibrarian.net/358480279/direnv_2.15.0-1_arm64.deb -o direnv.deb
RUN dpkg -i direnv.deb

RUN git clone https://github.com/prisma/prisma-engines.git

WORKDIR prisma-engines

RUN direnv allow
RUN cargo build --release

FROM node:14.13.1-buster as builder

COPY --from=prisma-build /prisma-engines/target/release/query-engine /prisma-arm64/query-engine
COPY --from=prisma-build /prisma-engines/target/release/migration-engine /prisma-arm64/migration-engine
COPY --from=prisma-build /prisma-engines/target/release/introspection-engine /prisma-arm64/introspection-engine
COPY --from=prisma-build /prisma-engines/target/release/prisma-fmt /prisma-arm64/prisma-fmt

COPY .env /prisma-arm64/

RUN chmod +x prisma-arm64/*

CMD tail -f /dev/null
