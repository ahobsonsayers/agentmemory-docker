# agentmemory-docker

A lightweight Docker image that makes it quick and easy to set up and run [agentmemory](https://github.com/rohitg00/agentmemory).

## Why

[agentmemory](https://github.com/rohitg00/agentmemory) is an excellent tool for providing persistent memory to your AI agents.

Currently however, using it requires installing it locally via npm or deploying it to a hosted service like Railway. I prefer to spin up services like this in a Docker container, whether locally or on a server, as doing so significantly simplifies the deployment process and provides a standard interface across environments.

Unfortunately, agentmemory doesn't currently publish an official docker image, so I cannot do this 😔

I built this project to fill that gap. It provides a consistently up-to-date, tagged Docker image for agentmemory that is automatically rebuilt for each release and pushed to Docker Hub 🐋

We build agentmemory from scratch with a couple of minor patches (see [./patches](./patches)) so that it works in properly in docker, and so the final image is lightweight.

## Running

Create the data volume first:

```bash
docker volume create agentmemory-data
```

Then run:

```bash
docker run -d -p 3111:3111 -p 3113:3113 -v agentmemory-data:/data arranhs/agentmemory:latest
```

Or with Docker Compose:

```bash
docker compose up -d
```

where your compose looks like the below or [./compose.yaml](./compose.yaml)

```yaml
services:
  agentmemory:
    image: arranhs/agentmemory:latest
    restart: unless-stopped
    ports:
      - 3111:3111 # API
      - 3113:3113 # UI
    volumes:
      - agentmemory-data:/data

volumes:
  agentmemory-data:
```

| Port | Service |
|------|---------|
| 3111 | API |
| 3113 | UI |

## Configuration

To enable authentication, set the `AGENTMEMORY_SECRET` environment variable.

You can securely generate a token with:

```bash
openssl rand -hex 32
```

## Environment Variables

This Docker project deploys the AgentMemory **server**. 

The variables below configure the backend runtime. Client-side variables (used by the CLI or MCP shims) are listed at the bottom purely for reference.

### Authentication

| Variable | Default | Description |
|---|---|---|
| `AGENTMEMORY_SECRET` | - | Shared secret used to authenticate remote clients against this server. Set this for any non-local deployment. |

### Features

| Variable | Default | Description |
|---|---|---|
| `AGENTMEMORY_TOOLS` | `all` | `core` or `all` — the tool surface exposed to MCP clients. |
| `AGENTMEMORY_AUTO_COMPRESS` | `false` | Run LLM compression on every observation batch to generate memories. |
| `AGENTMEMORY_REFLECT` | `false` | Periodically auto-synthesize lessons and insights from memories. |
| `CONSOLIDATION_ENABLED` | `false` | Run the 4-tier consolidation pipeline (memories → semantic → procedural). |
| `CONSOLIDATION_DECAY_DAYS` | `30` | Age (days) after which non-reinforced memories decay. |
| `LESSON_DECAY_ENABLED` | `true` | Daily decay sweep of unreinforced, low-confidence lessons. |
| `GRAPH_EXTRACTION_ENABLED` | `false` | Extract concept-graph edges on remember for graph-traversal recall. |
| `GRAPH_EXTRACTION_BATCH_SIZE` | `8` | Memories per graph-extraction batch. |
| `AGENTMEMORY_IMAGE_EMBEDDINGS` | `false` | Experimental: Enable image embeddings when an image provider is present. |
| `AGENT_ID` | - | Optional identifier for multi-agent setups. |
| `AGENTMEMORY_AGENT_SCOPE` | `shared` | Scope for multi-agent memory access; use `isolated` to scope recall to specific agents. |
| `TEAM_MODE` | - | Team sharing mode (e.g., `shared`). |
| `TEAM_ID` | - | Used alongside `TEAM_MODE` to scope memories to a specific team. |
| `USER_ID` | - | Used alongside `TEAM_MODE` to scope memories to a specific user. |

### Model Providers

Provider keys are only required if you want to use external embeddings or if you enable LLM-dependent features (such as `AGENTMEMORY_AUTO_COMPRESS`, `AGENTMEMORY_REFLECT`, or `CONSOLIDATION_ENABLED`). 

If no LLM keys are provided, AgentMemory disables LLM features and uses fast, zero-LLM "synthetic compression" instead.

#### OpenAI
| Variable | Default | Description |
|---|---|---|
| `OPENAI_BASE_URL` | - | Base URL for any OpenAI-compatible API (vLLM, LM Studio, Ollama, DeepSeek, etc). |
| `OPENAI_API_KEY` | - | Enables OpenAI-compatible embeddings and the OpenAI-compatible LLM path. |
| `OPENAI_MODEL` | - | Model name for the OpenAI-compatible LLM provider. |
| `OPENAI_API_KEY_FOR_LLM` | `true` | Set to `false` if using `OPENAI_API_KEY` for embeddings only. |
| `OPENAI_REASONING_EFFORT` | - | Passed through to supported reasoning models. |
| `OPENAI_API_VERSION` | - | Azure OpenAI API version. |
| `OPENAI_TIMEOUT_MS` | `60000` | Legacy compatibility alias for `AGENTMEMORY_LLM_TIMEOUT_MS`. |

#### Anthropic
| Variable | Default | Description |
|---|---|---|
| `ANTHROPIC_BASE_URL` | - | Override for Anthropic-compatible proxies / Azure AI Foundry. |
| `ANTHROPIC_API_KEY` | - | Enables Anthropic features. |
| `ANTHROPIC_MODEL` | `claude-sonnet-4-20250514` | Default Anthropic model. |
| `AGENTMEMORY_ALLOW_AGENT_SDK` | `false` | Opt-in Claude-subscription fallback (spawns child sessions). |

#### Gemini
| Variable | Default | Description |
|---|---|---|
| `GEMINI_API_KEY` | - | Enables Gemini features. |
| `GOOGLE_API_KEY` | - | Alias for `GEMINI_API_KEY`. |
| `GEMINI_MODEL` | `gemini-2.5-flash` | Default Gemini model. |

#### Voyage
| Variable | Default | Description |
|---|---|---|
| `VOYAGE_API_KEY` | - | Voyage API key (optimised for code embeddings). |

#### MiniMax
| Variable | Default | Description |
|---|---|---|
| `MINIMAX_API_KEY` | - | Enables MiniMax provider. |
| `MINIMAX_MODEL` | `MiniMax-M2.7` | Default MiniMax model. |

#### OpenRouter
| Variable | Default | Description |
|---|---|---|
| `OPENROUTER_API_KEY` | - | Enables OpenRouter features. |
| `OPENROUTER_MODEL` | - | Default OpenRouter model. |

#### General LLM Settings
| Variable | Default | Description |
|---|---|---|
| `AGENTMEMORY_LLM_TIMEOUT_MS` | `60000` | Global timeout for LLM requests (in milliseconds). |
| `MAX_TOKENS` | `4096` | Cap LLM completion tokens for compression / summarise calls. |
| `FALLBACK_PROVIDERS` | - | Comma-separated chain tried after the primary provider returns an error (e.g., `anthropic,gemini`). |

### Embeddings

Embeddings are auto-detected based on the provider keys above. 

If no compatible provider key is found, AgentMemory defaults to running a local CPU-based embedding model (`Xenova/all-MiniLM-L6-v2`, 384-dim). You can explicitly override the detection logic using the variables below.

| Variable | Default | Description |
|---|---|---|
| `EMBEDDING_PROVIDER` | `local` | Override detection: `local`, `openai`, `gemini`, `cohere`, `voyage`, or `openrouter`. |
| `OPENAI_EMBEDDING_MODEL` | `text-embedding-3-small` | Override the default OpenAI embedding model. |
| `OPENAI_EMBEDDING_DIMENSIONS` | - | Explicitly set dimensions if using a non-standard OpenAI model (e.g., `1536`). |
| `COHERE_API_KEY` | - | Cohere API key. |
| `OPENROUTER_EMBEDDING_MODEL`| `openai/text-embedding-3-small` | Set when `EMBEDDING_PROVIDER=openrouter`. |

### Search Tuning

| Variable | Default | Description |
|---|---|---|
| `MAX_OBS_PER_SESSION` | `500` | Per-session observation cap before consolidation kicks in. |
| `TOKEN_BUDGET` | `2000` | Max tokens injected via context per session. |
| `BM25_WEIGHT` | `0.4` | Hybrid search weight for BM25 leg. |
| `VECTOR_WEIGHT` | `0.6` | Hybrid search weight for vector leg. |
| `AGENTMEMORY_GRAPH_WEIGHT` | `0.2` | Graph traversal bonus on smart-search ranking. |
| `SUMMARIZE_CHUNK_SIZE` | `400` | Chunk size (observations) when map-reducing large sessions. |
| `SUMMARIZE_CHUNK_CONCURRENCY`| `6` | Parallel chunk LLM calls during chunked summarize. |

### Diagnostics, Recovery & Backups

| Variable | Default | Description |
|---|---|---|
| `OBSIDIAN_AUTO_EXPORT` | `false` | Automatically mirror agent memories, rules and lessons to `~/.agentmemory/vault/` as linked Markdown notes. |
| `SNAPSHOT_ENABLED` | `false` | Periodic snapshots of state_store and stream_store. |
| `SNAPSHOT_DIR` | `~/.agentmemory/snapshots`| Path for state snapshots. |
| `SNAPSHOT_INTERVAL` | `3600` | Seconds between snapshots. |
| `AGENTMEMORY_DROP_STALE_INDEX` | `false` | Recovery flag for stale-index issues (drops BM25/vector index on startup). |
| `REBUILD_EMBED_BATCH_SIZE` | `32` | Batch size used for embedding rebuild operations. |
| `AGENTMEMORY_SUPPRESS_COST_WARNING` | `false` | Suppresses the warning shown for premium-cost OpenRouter model selections. |

***

## Client Environment Variables

These variables are for AgentMemory clients, MCP shims, or local CLI integrations communicating with the server. **They are not part of this server container's runtime configuration** and are listed here for reference.

### Connection

| Variable | Default | Description |
|---|---|---|
| `AGENTMEMORY_URL` | `http://localhost:3111` | REST base URL a client uses to reach an AgentMemory server. |
| `AGENTMEMORY_VIEWER_URL` | `http://localhost:3113` | Override the viewer URL printed by `agentmemory status`. |
| `AGENTMEMORY_REQUIRE_HTTPS` | `false` | Safety check that refuses to send the secret over plain HTTP to non-loopback hosts. |
| `AGENTMEMORY_PROBE_TIMEOUT_MS`| `2000` | MCP shim livez probe timeout. |
| `AGENTMEMORY_FORCE_PROXY` | `false` | Skip the MCP shim livez probe and force direct proxying to `AGENTMEMORY_URL`. |

### Agent Integrations

| Variable | Default | Description |
|---|---|---|
| `AGENTMEMORY_INJECT_CONTEXT` | `false` | Automatically injects recalled memory into agent flows on the client side. |
| `AGENTMEMORY_SLOTS` | `memory` | Comma-separated plugin slot names the CLI should claim. |
| `CLAUDE_MEMORY_BRIDGE` | `false` | Enables bi-directional sync with Claude Code's native `MEMORY.md`. |
| `CLAUDE_MEMORY_LINE_BUDGET` | `200` | When `CLAUDE_MEMORY_BRIDGE` is true, configures the max lines allowed to be injected into `MEMORY.md`. |
| `CLAUDE_PLUGIN_ROOT` | - | Used to specify the root directory for Claude Code plugins/hooks. |

### Miscellaneous

| Variable | Default | Description |
|---|---|---|
| `STANDALONE_MCP` | `false` | Bypass the worker and run `@agentmemory/mcp` in-process. |
| `STANDALONE_PERSIST_PATH` | `~/.agentmemory/local.db`| Path used by the standalone MCP shim's local fallback store. |
| `AGENTMEMORY_EXPORT_ROOT` | `~/agentmemory-backup`| Default destination for `agentmemory export`. |
| `AGENTMEMORY_DEBUG` | `false` | Trace MCP shim probe and fallback decisions. |

