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

Below is a selection of the most relevant environment variables for this Docker image. A few variables that do not apply to this containerized setup have been omitted.

### Authentication & Security

| Variable | Description | Default |
|---|---|---|
| `AGENTMEMORY_SECRET` | Bearer token for REST API + viewer | - |

### LLM Provider

| Variable | Description | Default |
|---|---|---|
| `OPENAI_API_KEY` | OpenAI API key | - |
| `OPENAI_BASE_URL` | OpenAI base URL | `https://api.openai.com` |
| `ANTHROPIC_API_KEY` | Anthropic API key | - |
| `ANTHROPIC_BASE_URL` | Anthropic base URL | `https://api.anthropic.com` |
| `GEMINI_API_KEY` | Gemini API key | - |
| `MINIMAX_API_KEY` | Minimax API key | - |
| `OPENROUTER_API_KEY` | OpenRouter API key | - |

### Embeddings

| Variable | Description | Default |
|---|---|---|
| `EMBEDDING_PROVIDER` | Embedding provider (local, openai, gemini, cohere, openrouter, voyage) | `local` |
| `OPENAI_EMBEDDING_MODEL` | OpenAI embedding model | `text-embedding-3-small` |
| `GEMINI_EMBEDDING_MODEL` | Gemini embedding model | `gemini-embedding-001` |
| `COHERE_API_KEY` | Cohere API key | - |
| `OPENROUTER_API_KEY` | OpenRouter API key | - |
| `VOYAGE_API_KEY` | Voyage AI API key | - |

### Compression & Summarization

| Variable | Description | Default |
|---|---|---|
| `AGENTMEMORY_AUTO_COMPRESS` | Run LLM compression on every observation | `false` |
| `AGENTMEMORY_ALLOW_AGENT_SDK` | Allow Claude SDK fallback | `false` |
| `MAX_TOKENS` | Max tokens for LLM completion | `4096` |

### Search & Memory

| Variable | Description | Default |
|---|---|---|
| `BM25_WEIGHT` | Hybrid search weight for BM25 | `0.4` |
| `VECTOR_WEIGHT` | Hybrid search weight for vector | `0.6` |
| `TOKEN_BUDGET` | Max tokens injected per session | `2000` |
| `MAX_OBS_PER_SESSION` | Per-session observation cap | `500` |

### Features

| Variable | Description | Default |
|---|---|---|
| `CONSOLIDATION_ENABLED` | Run 4-tier consolidation | `false` |
| `CONSOLIDATION_DECAY_DAYS` | Days before memory decay | `30` |
| `GRAPH_EXTRACTION_ENABLED` | Extract knowledge graph | `false` |

### Project

| Variable | Description | Default |
|---|---|---|
| `AGENTMEMORY_PROJECT` | Project name for memory namespace | `default` |
