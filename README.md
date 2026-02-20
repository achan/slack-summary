# Tesseract

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

## Slack App Setup

Create a Slack app at [api.slack.com/apps](https://api.slack.com/apps) and
configure the following:

### User Token Scopes (OAuth & Permissions)

- `channels:history` — view messages in public channels
- `channels:read` — list public channels
- `groups:history` — view messages in private channels
- `groups:read` — list private channels
- `im:history` — view messages in DMs
- `im:read` — list DMs
- `mpim:history` — view messages in group DMs
- `mpim:read` — list group DMs
- `reactions:read` — view emoji reactions
- `search:read` — search workspace content
- `users:read` — resolve user names

### Event Subscriptions

Enable events and set the Request URL to your cloudflared tunnel
(e.g., `https://your-tunnel.example.com/api/slack/events`).

Subscribe to these events **on behalf of users** (not bot events):

- `message.channels`
- `message.groups`
- `message.im`
- `message.mpim`
- `reaction_added`

After configuring scopes and events, install the app to your workspace
and copy the **User OAuth Token** (`xoxp-...`) and **Signing Secret**
into your `.env.local`.

## Prerequisites

- Ruby 3.4.2
- SQLite
- tmux (for the worktree dev environment)
- [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/) (for receiving Slack webhooks)

## Getting Started

Clone the repo and install dependencies:

```sh
git clone <repo-url>
cd tesseract
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

This creates a worktree at `~/repos/tesseract-worktrees/my-feature`
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

## Production

The app runs on a home server behind a cloudflared tunnel via
`bin/prod`. Systemd manages the process and auto-deploys.

### Initial setup

Make sure your `.env` is populated, then install the systemd units:

```sh
sudo cp deploy/tesseract.service /etc/systemd/system/
sudo cp deploy/tesseract-deploy.service /etc/systemd/system/
sudo cp deploy/tesseract-deploy.timer /etc/systemd/system/
sudo systemctl daemon-reload
```

Start the app and enable auto-deploy:

```sh
sudo systemctl enable --now tesseract
sudo systemctl enable --now tesseract-deploy.timer
```

The timer polls for new commits on `main` every minute. When it
detects changes it runs `bin/deploy`, which pulls the latest code,
installs dependencies and precompiles assets only when their source
files changed, runs `db:prepare`, and restarts the service.

### Useful commands

```sh
systemctl status tesseract              # app status
journalctl -u tesseract -f              # follow app logs
systemctl list-timers tesseract-deploy* # next scheduled deploy check
tail -f log/deploy.log                  # deploy history
bin/deploy --force                      # manual deploy
bin/deploy --check                      # exit 0 if new commits available
```

### Configuration

`bin/deploy` reads these environment variables (all optional):

| Variable | Default | Description |
|---|---|---|
| `DEPLOY_BRANCH` | `main` | Branch to deploy from |
| `DEPLOY_REMOTE` | `origin` | Git remote to fetch |
| `DEPLOY_SERVICE` | `tesseract` | Systemd service to restart |

Edit the `WorkingDirectory` and `EnvironmentFile` paths in the
service files if your checkout lives somewhere other than
`/home/user/tesseract`.
