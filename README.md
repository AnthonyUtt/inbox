# Inbox

A minimalist single-page app for capturing ideas as quickly and painlessly as possible. Type your thought, hit save, and it's written to a markdown file. Designed to be installed as a PWA on your phone's home screen.

## How It Works

The page has a single textarea. The first line becomes the title, everything after becomes the content. On submit, a markdown file is written to disk:

```
---
created-at: 2026-03-31T12:00:00Z
---

# My Idea

The details of my idea...
```

The filename is derived from the title: `my_idea.md`, saved to the directory specified by `INBOX_WORKING_DIR`.

## Development

```sh
bin/setup
bin/dev
```

This starts Puma on port 3000 with esbuild in watch mode.

## Testing

```sh
bin/rails test          # all tests
bin/ci                  # full CI pipeline (lint, security, tests)
```

## Docker

```sh
docker build -t inbox .
docker run -d \
  -p 80:80 \
  -e RAILS_MASTER_KEY=<key> \
  -e RAILS_HOST=inbox.example.com \
  -v /path/to/ideas:/inbox \
  inbox
```

The container creates an `/inbox` directory by default. Bind-mount a volume to persist your ideas.

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `INBOX_WORKING_DIR` | Directory where markdown files are saved | `/inbox` |
| `RAILS_HOST` | Allowed hostname (for production behind a reverse proxy) | — |
| `RAILS_MASTER_KEY` | Decrypts Rails credentials (required in production) | — |
| `PORT` | Server port | `3000` |
