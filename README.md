### Prisma Binaries for arm64
This is a temporary solution for building custom binaries for arm64.

**As of now I've only verified this works on debian images. On alpine images it has issues due to the lack of glibc package.**

The location of the binaries are in: `/prisma-arm64`
The `.env` file is also located at `/prisma-arm64/.env`

#### Use it as a FROM base image
```dockerfile
FROM jaywizard/prisma-arm64 as prisma-builder
```

#### Copy binaries to your image
```dockerfile
FROM node:14.13.1-buster as builder

COPY --from=prisma-builder /prisma-arm64 /prisma-arm64

# Use provided .env file (copy it wherever you need to)
COPY /prisma-arm64/.env ./prisma/.env

# Verify .env file is being used
RUN npx prisma -v
```

#### Using with yarn
```dockerfile
# Install prisma
RUN yarn install --ignore-scripts

RUN yarn prisma -v
RUN yarn prisma generate
```

Hopefully the prisma team will officially support arm64 one day. If this image needs updated, please open a GH issue or create a PR.