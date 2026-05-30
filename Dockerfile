ARG AGENTMEMORY_VERSION=0.9.24
ARG III_VERSION=0.11.2

#####################
# tini image
#####################
FROM debian:stable-slim AS tini-image

# Install tini 
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tini

#####################
# iii image
#####################
FROM iiidev/iii:${III_VERSION} AS iii-image

#####################
# Data image
#####################
FROM debian:stable-slim AS data-image

# Create empty data directory 
RUN mkdir -p /data

#####################
# Builder image
#####################
FROM node:26 AS builder

ARG AGENTMEMORY_VERSION

WORKDIR /app

COPY patches /tmp/patches

RUN git clone --depth 1 --branch v${AGENTMEMORY_VERSION} \
      https://github.com/rohitg00/agentmemory . && \
    git apply /tmp/patches/bind-all-interfaces.patch && \
    npm install --ignore-scripts --legacy-peer-deps --include=optional && \
    npm run build && \
    cp iii-config.docker.yaml dist/iii-config.yaml

#####################
# Distribution image
#####################
FROM gcr.io/distroless/nodejs26-debian13

# Add dependencies
COPY --from=tini-image /usr/bin/tini /usr/local/bin/tini
COPY --from=iii-image /app/iii /usr/local/bin/iii

WORKDIR /app

# Add agentmemory
COPY --chown=65532:65532 --from=builder /app/package.json ./package.json
COPY --chown=65532:65532 --from=builder /app/dist ./dist
COPY --chown=65532:65532 --from=builder /app/node_modules ./node_modules

# Add data folder
COPY --chown=65532:65532 --from=data-image /data /data

USER 65532

VOLUME /data

# Expose ports:
# 3111 = API
# 3112 = Streams
# 3113 = UI
EXPOSE 3111 3112 3113

ENTRYPOINT ["tini", "--", "/nodejs/bin/node", "./dist/cli.mjs"]
