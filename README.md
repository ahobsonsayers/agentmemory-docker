# agentmemory-docker

A lightweight docker image that makes it simple and quick to setup and run [agentmemory](https://github.com/rohitg00/agentmemory)

## Why

[agentmemory](https://github.com/rohitg00/agentmemory) is a great tool to provide persistent memory so it remembers everything.

However at the moment it requires you to install it with npm to use it, or deploy it to a hosted service like railway.

My preference is different from this - for a service like this I want to be able to spin it up in a docker container, either on my local machine or my server. This simplifies and unifies the run process significantly, and allows for a common interface. Sadly agentmemory does not have a official image published to dockerhub, so I cannot easily do this 😔

I built this image to fill that gap - a consistently up to date and tagged docker image for agentmemory - rebuilt automatically for each version and pushed to dockerhub 🐋

## Running

```bash
docker run -d -p 3111:3111 -v ./data:/data arranhs/agentmemory:latest
```

Or with docker compose:

```yaml
services:
  agentmemory:
    image: arranhs/agentmemory:latest
    ports:
      - 3111:3111
    volumes:
      - ./data:/data
    restart: unless-stopped
```

> [!important]
> Create the `./data` directory on the host before running to prevent permission issues.

## Configuration

To enable authentication set `AGENTMEMORY_SECRET`.

You can create a token with:

```bash
openssl rand -hex 32
```

## Environment Variables

This is just a selection of relevant environment variables. Some that do not apply have been omitted.

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
