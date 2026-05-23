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

Below is the full list of environment variables for this Docker image. A few variables that do not apply to this containerized setup have been omitted.

### Authentication & Security

| Variable | Description | Default |
|---|---|---|
| `AGENTMEMORY_SECRET` | Bearer token for REST API + viewer | - |

### Features

| Variable | Description | Default |
|---|---|---|
| `CONSOLIDATION_ENABLED` | Run 4-tier consolidation pipeline | `false` |
| `CONSOLIDATION_DECAY_DAYS` | Days before memory decay | `30` |
| `GRAPH_EXTRACTION_ENABLED` | Extract knowledge graph edges | `false` |
| `GRAPH_EXTRACTION_BATCH_SIZE` | Memories per graph-extraction batch | `8` |
| `AGENTMEMORY_INJECT_CONTEXT` | Inject recalled memories into agent prompts | `false` |
| `AGENTMEMORY_AUTO_COMPRESS` | Run LLM compression on every observation | `false` |
| `AGENTMEMORY_REFLECT` | Auto-synthesize lessons from memories | `false` |
| `AGENTMEMORY_IMAGE_EMBEDDINGS` | Enable image embeddings | `false` |
| `AGENTMEMORY_DROP_STALE_INDEX` | Drop stale BM25 / vector index on startup | `false` |

### LLM Provider

| Variable | Description | Default |
|---|---|---|
| `OPENAI_BASE_URL` | OpenAI base URL | `https://api.openai.com` |
| `OPENAI_API_KEY` | OpenAI API key | - |
| `OPENAI_MODEL` | OpenAI model for completions | `gpt-4o-mini` |
| `OPENAI_TIMEOUT_MS` | OpenAI timeout (ms) | `60000` |
| `ANTHROPIC_BASE_URL` | Anthropic base URL | `https://api.anthropic.com` |
| `ANTHROPIC_API_KEY` | Anthropic API key | - |
| `ANTHROPIC_MODEL` | Default Anthropic model | `claude-sonnet-4-20250514` |
| `GEMINI_API_KEY` | Gemini API key | - |
| `GOOGLE_API_KEY` | Alias for GEMINI_API_KEY | - |
| `GEMINI_MODEL` | Default Gemini model | `gemini-2.5-flash` |
| `MINIMAX_API_KEY` | Minimax API key | - |
| `MINIMAX_MODEL` | Default Minimax model | `MiniMax-M2.7` |
| `OPENROUTER_API_KEY` | OpenRouter API key | - |
| `OPENROUTER_MODEL` | Default OpenRouter model | `anthropic/claude-sonnet-4-20250514` |
| `FALLBACK_PROVIDERS` | Comma-separated fallback chain | - |

### LLM Settings

| Variable | Description | Default |
|---|---|---|
| `MAX_TOKENS` | Max LLM completion tokens | `4096` |
| `AGENTMEMORY_LLM_TIMEOUT_MS` | LLM / embedding timeout (ms) | `60000` |
| `AGENTMEMORY_ALLOW_AGENT_SDK` | Allow Claude SDK fallback | `false` |

### Embedding Provider

| Variable | Description | Default |
|---|---|---|
| `EMBEDDING_PROVIDER` | Embedding provider | `` local \| openai \| voyage \| cohere \| gemini \| openrouter `` |
| `OPENAI_EMBEDDING_MODEL` | Embedding model (openai) | `text-embedding-3-small` |
| `OPENAI_EMBEDDING_DIMENSIONS` | Embedding dimensions | `1536` |
| `GEMINI_API_KEY` | Gemini API key | - |
| `COHERE_API_KEY` | Cohere API key | - |
| `VOYAGE_API_KEY` | Voyage AI API key | - |
| `OPENROUTER_EMBEDDING_MODEL` | Embedding model (openrouter) | `openai/text-embedding-3-small` |

### Search Tuning

| Variable | Description | Default |
|---|---|---|
| `BM25_WEIGHT` | Hybrid search weight for BM25 | `0.4` |
| `VECTOR_WEIGHT` | Hybrid search weight for vector | `0.6` |
| `AGENTMEMORY_GRAPH_WEIGHT` | Graph traversal bonus | `0.2` |
| `TOKEN_BUDGET` | Max tokens injected per session | `2000` |
| `MAX_OBS_PER_SESSION` | Per-session observation cap | `500` |
| `SUMMARIZE_CHUNK_SIZE` | Chunk size for summarize | `400` |
| `SUMMARIZE_CHUNK_CONCURRENCY` | Parallel chunk LLM calls | `6` |

### Project

| Variable | Description | Default |
|---|---|---|
| `AGENTMEMORY_PROJECT` | Project name for memory namespace | `default` |

## CLI Only Environment Variables

The following environment variables are supported by the agentmemory CLI,
and are not relevant to this image. You may however want to use them to
configure your client.

### MCP Client

| Variable | Description | Default |
|---|---|---|
| `AGENTMEMORY_URL` | REST base URL | `http://localhost:3111` |
| `AGENTMEMORY_VIEWER_URL` | Viewer URL override | `http://localhost:3113` |
| `AGENTMEMORY_TOOLS` | Tools exposed to MCP clients | `` core \| all `` |
| `AGENTMEMORY_SLOTS` | Comma-separated plugin slots | `memory` |
| `AGENTMEMORY_FORCE_PROXY` | Skip MCP shim livez probe | `false` |
| `AGENTMEMORY_PROBE_TIMEOUT_MS` | MCP shim livez probe timeout (ms) | `2000` |
| `AGENTMEMORY_DEBUG` | Trace MCP shim to stderr | `false` |

### Integrations

| Variable | Description | Default |
|---|---|---|
| `CLAUDE_MEMORY_BRIDGE` | Mirror memories into CLAUDE.md | `false` |
| `CLAUDE_PROJECT_PATH` | Project path for CLAUDE.md | - |
| `CLAUDE_MEMORY_LINE_BUDGET` | Lines of memory in CLAUDE.md | `200` |
| `OBSIDIAN_AUTO_EXPORT` | Auto-export to Obsidian | `false` |

### Storage & Export

| Variable | Description | Default |
|---|---|---|
| `AGENTMEMORY_EXPORT_ROOT` | Default export path | `~/agentmemory-backup` |
| `STANDALONE_MCP` | Run MCP shim in-process | - |
| `STANDALONE_PERSIST_PATH` | Local fallback store path | `~/.agentmemory/local.db` |
| `SNAPSHOT_ENABLED` | Enable periodic snapshots | `false` |
| `SNAPSHOT_DIR` | Snapshot directory | `~/.agentmemory/snapshots` |
| `SNAPSHOT_INTERVAL` | Seconds between snapshots | `3600` |

### Team Sharing

| Variable | Description | Default |
|---|---|---|
| `TEAM_MODE` | Team sharing mode | `` shared `` |
| `TEAM_ID` | Team identifier | - |
| `USER_ID` | User identifier | - |
