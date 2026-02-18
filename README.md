# Slack Summary

Multi-workspace Slack event ingestion, summarization, and action-item
extraction. Built on Rails 8 with SQLite, running locally behind a
cloudflared tunnel.

A single Slack app is installed into each workspace. User tokens
(`xoxp-`) give visibility into public channels, private channels, and
group DMs without needing bot invitations. Incoming events are stored
in SQLite, then a background job summarizes activity and extracts
action items using Claude.

See [ARCHITECTURE.md](ARCHITECTURE.md) for full design details,
database schema, and API documentation.

## Prerequisites

- Ruby 3.4.2
- SQLite
- tmux (for the worktree dev environment)
- [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/) (for receiving Slack webhooks)

## Getting Started

Clone the repo and install dependencies:

```sh
git clone <repo-url>
cd slack-summary
bin/setup --skip-server
```

Copy the example env file and fill in your Slack signing secret and
encryption keys:

```sh
cp .env.example .env
bin/rails db:encryption:init  # paste output into .env
```

Start the development server:

```sh
bin/dev
```

This runs the Rails server (port 6000) and Solid Queue job worker via
`Procfile.dev`.

## Worktree Development

This repo uses git worktrees so multiple feature branches can run
simultaneously, each with its own server on a separate port.

### Create a worktree

From the main repo directory:

```sh
bin/create-worktree.sh my-feature
```

This creates a worktree at `~/repos/slack-summary-worktrees/my-feature`
on a new `feature/my-feature` branch, symlinks your `.env`, and runs
`bundle install`.

### Start a worktree session

From inside the worktree directory:

```sh
bin/start-worktree.sh
```

This launches a tmux session with:
- **Window 1 (main):** vim (top), shell (bottom-left), Claude Code
  (bottom-right)
- **Window 2 (server):** Rails server + job worker on the first
  available port starting from 6000

### Remove a worktree

From the main repo directory:

```sh
bin/remove-worktree.sh my-feature
```
