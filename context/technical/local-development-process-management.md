# Local Development Process Management (Overmind / Procfile)

## Context

This project runs multiple long-lived processes in development:

- Rails web server
- SolidQueue worker
- GoodJob worker

We want a simple, repeatable way to start/stop them with readable, separated logs.

## Decision

### Overmind + Procfile

Local development uses [Overmind](https://github.com/DarthSim/overmind) (tmux-based) with `Procfile.dev` to run multiple processes concurrently.

- Install tools on macOS via `make bootstrap` (Homebrew required)
- Start everything via `make dev`

### Make targets

- `make dev`: start web + solidqueue + goodjob via Overmind
- `make dev-web`: start only the Rails web server
- `make dev-solidqueue`: start only the SolidQueue worker
- `make dev-goodjob`: start only the GoodJob worker
- `make dev-stop`: stop Overmind and clean up any stale state

### Notes / gotchas

- `make dev` will ensure Postgres is running and run `bin/rails db:prepare` before starting processes.
- `make dev-solidqueue` sets `DISABLE_BOOTSNAP=1` by default to avoid rare native crashes on macOS. Set `DISABLE_BOOTSNAP=0` if you want it enabled.

## Alternatives Considered

- **Single-process dev (web only)**: rejected; we want to exercise both adapters with real worker processes.
- **Foreman/Overmind alternatives**: acceptable, but Overmind provides good tmux-based log separation and is easy to bootstrap on macOS.

## Consequences

### Positive

- One command starts the whole local environment with clear logs.
- Easy to run only the specific component you’re working on.

### Negative

- Adds a tmux/Overmind dependency if you want the multi-process dev experience (web-only still works).

