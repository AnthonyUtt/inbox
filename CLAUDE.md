# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- `bin/setup` — install deps and prepare DB (`--skip-server` to skip starting dev server)
- `bin/dev` — start dev server (Puma + esbuild watch via foreman, port 3000)
- `bin/rails test` — run all tests
- `bin/rails test test/controllers/ideas_controller_test.rb` — run a single test file
- `bin/rails test test/controllers/ideas_controller_test.rb:15` — run a single test by line
- `bin/rubocop` — lint (rubocop-rails-omakase style)
- `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error` — security scan
- `bin/bundler-audit` — gem vulnerability audit
- `bin/ci` — full CI pipeline (setup, lint, security, tests)
- `docker build -t inbox .` — build production image

## Architecture

Minimalist single-page Rails 8.1 app that captures ideas and writes them as markdown files to the filesystem. No database models — SQLite is only used for Solid Cache/Queue/Cable infrastructure.

**Flow**: User submits textarea → `IdeasController#create` parses first line as title, rest as content → writes markdown file to `INBOX_WORKING_DIR` → responds with Turbo Stream (replaces form + appends toast).

**Key files**:
- `app/controllers/ideas_controller.rb` — all business logic (parse input, write file, error handling)
- `app/views/ideas/` — `new.html.erb` (page), `_form.html.erb` (textarea), `_toast.html.erb` (notifications)
- `app/javascript/controllers/inbox_controller.js` — textarea focus after Turbo Stream replace
- `app/javascript/controllers/toast_controller.js` — auto-dismiss toasts after 3s

**Frontend**: Hotwire (Turbo + Stimulus), esbuild, Propshaft. No CSS framework — vanilla CSS in `app/assets/stylesheets/application.css`.

**PWA**: Enabled — manifest at `app/views/pwa/manifest.json.erb`, service worker at `app/views/pwa/service-worker.js`.

## Environment Variables

- `INBOX_WORKING_DIR` — directory for markdown files (default: `/inbox`)
- `RAILS_HOST` — allowed host in production (for reverse proxy)
- `RAILS_MASTER_KEY` — required in production
- `PORT` — server port (default: 3000)

## Docker

Production image creates `/inbox` owned by non-root user (uid 1000). Mount a volume to persist ideas. Uses Thruster as HTTP accelerator in front of Puma.
