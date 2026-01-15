# Update Production Queue DB Connections + Worker Threads

## Context

This command exists to keep benchmarks FAIR. Apply the same concurrency shape to SolidQueue and GoodJob.

**Fairness rules (non-negotiable):**
- Do NOT run more processes for one adapter than the other.
- Do NOT run more machines for one adapter than the other.
- Do NOT mix "2 processes with N threads" on SolidQueue vs "1 process" on GoodJob (or vice versa).
- Keep concurrency symmetric unless explicitly instructed to do otherwise.

Use this command when you need to change production queue DB connections and keep worker thread counts aligned for SolidQueue and GoodJob.

## Instructions (for AI agent)

1. Update the production queue DB pool:
   - Edit `config/database.yml`
   - Under `production:` → `queue:`, set `max_connections` to the desired number (use one consistent value; do not set `pool`).
2. Update SolidQueue worker threads:
   - Edit `config/queue.yml`
   - Under `production:` → `workers:`, set `threads` to the same target number (or another explicit value if instructed).
3. Update GoodJob worker threads:
   - Edit `fly.toml`
   - Under `[processes]`, set `goodjob` to `bundle exec good_job start --max-threads=<target>`.
4. Do not change local dev defaults unless explicitly requested.
5. Run lint checks for edited files and report any errors.

## Example target

Target: 25
