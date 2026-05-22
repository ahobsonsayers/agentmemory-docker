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

RUN AGENTMEMORY_DIR="/root/.bun/install/global/node_modules/@agentmemory/agentmemory" && \
    cp "$AGENTMEMORY_DIR/dist/iii-config.docker.yaml" "$AGENTMEMORY_DIR/dist/iii-config.yaml" && \
    sed -i 's/server.listen(currentPort, "127.0.0.1");/server.listen(currentPort, "0.0.0.0");/g' "$AGENTMEMORY_DIR/dist/index.mjs" && \
    sed -i 's/if (!isHostAllowed(req.headers.host, allowedHosts)) {/if (false) { \/\/ bind-all/g' "$AGENTMEMORY_DIR/dist/index.mjs"

RUN useradd agent --uid 1000 && \
    mkdir -p /data && \
    chown -R agent:agent /data /root

USER agent

# API and UI
EXPOSE 3111 3113

ENTRYPOINT ["/usr/bin/tini", "--", "/root/.bun/bin/agentmemory"]