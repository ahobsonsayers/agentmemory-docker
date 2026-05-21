ARG AGENTMEMORY_VERSION=0.9.21
ARG III_VERSION=0.11.2

FROM iiidev/iii:${III_VERSION} AS iii-image

FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    tini && \
    rm -rf /var/lib/apt/lists/*

COPY --from=iii-image /app/iii /usr/local/bin/iii

COPY --from=oven/bun:debian /usr/local/bin/bun /usr/local/bin/bunx /usr/local/bin/

RUN ln -s /usr/local/bin/bun /usr/local/bin/node

RUN bun install -g @agentmemory/agentmemory@${AGENTMEMORY_VERSION} --no-optional

COPY patches /tmp/patches

RUN AGENTMEMORY_DIR="/root/.bun/install/global/node_modules/@agentmemory/agentmemory/dist" && \
    cp "$AGENTMEMORY_DIR/iii-config.docker.yaml" "$AGENTMEMORY_DIR/iii-config.yaml" && \
    git apply /tmp/patches/bind-all.patch && \
    rm -rf /tmp/patches

RUN useradd agent --uid 1000 && \
    mkdir -p /data && \
    chown -R agent:agent /data /root

USER agent

# API and UI
EXPOSE 3111 3113

ENTRYPOINT ["/usr/bin/tini", "--", "/root/.bun/bin/agentmemory"]