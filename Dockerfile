ARG AGENTMEMORY_VERSION=0.9.21
ARG III_VERSION=0.11.2

FROM iiidev/iii:${III_VERSION} AS iii-image

FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    tini && \
    rm -rf /var/lib/apt/lists/*

COPY --from=iii-image /app/iii /usr/local/bin/iii

COPY --from=oven/bun:debian /usr/local/bin/bun /usr/local/bin/bunx /usr/local/bin/

RUN ln -s /usr/local/bin/bun /usr/local/bin/node

RUN bun install -g @agentmemory/agentmemory@${AGENTMEMORY_VERSION} --no-optional

RUN sed -i 's|host: 127.0.0.1|host: 0.0.0.0|g' /root/.bun/install/global/node_modules/@agentmemory/agentmemory/dist/iii-config.yaml && \
    sed -i 's|file_path: ./data/|file_path: /data/|g' /root/.bun/install/global/node_modules/@agentmemory/agentmemory/dist/iii-config.yaml

RUN useradd agent --uid 1000 && \
    mkdir -p /data && \
    chown -R agent:agent /data /root

USER agent

EXPOSE 3111 3112

ENTRYPOINT ["/usr/bin/tini", "--", "/root/.bun/bin/agentmemory"]
