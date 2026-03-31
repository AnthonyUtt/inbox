# Inbox

This app is intended to serve a singular purpose: to capture ideas as quickly
and painlessly as possible.

## Functionality

Single page, no authentication, minimalist style. Contents: a single textarea
in the center of the page. On submission, parse the textarea content using
template #1 below. Write the submission to a markdown file (template #2 below)
in the directory provided by the environment variable `$INBOX_WORKING_DIR`, with
a fallback to `/inbox` (inside the docker container).

**On Success**:
- Show a simple success toast to the user
- Reset the textarea
- Focus the textarea

**On Error**:
- Fail gracefully and surface a human-readable message to the user

### Templates

#### #1: Input Template

```
{title}

{content}
```

#### #2: Output Template

Save to `"#{$INBOX_WORKING_DIR}/#{title.underscore.parameterize(separator: '_')}.md"`

```
---
created-at: {now}
---

# {title}

{content}
```

## Deployment

The app will be deployed using Docker, so we should have a Dockerfile that
properly expects the `$INBOX_WORKING_DIR` variable. It will be run using
`docker run` as a systemd service, and the `/inbox` volume will be bound
properly at runtime. It will be behind a reverse-proxy on another machine, so
we should also add a RAILS_HOST variable/parameter for setting the host properly.
