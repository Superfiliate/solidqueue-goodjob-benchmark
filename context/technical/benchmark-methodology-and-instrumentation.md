# Benchmark Methodology and Instrumentation

## Context

To produce reliable, comparable results between SolidQueue and GoodJob, we need a consistent methodology for:
- Running benchmarks
- Collecting metrics
- Ensuring reproducibility
- Reporting results

This decision establishes the measurement approach before we build the benchmark harness.

## Decision

### Measurement Methodology

**Warmup Phase**
- Run a warmup period before collecting metrics to allow:
  - JIT compilation to stabilize
  - Database connections to establish
  - Caches to populate
  - System to reach steady state

**Measurement Phase**
- Collect metrics during a steady-state period after warmup
- Run multiple iterations to account for variance
- Use statistical methods to report confidence intervals

**Environment Control**
- Use consistent hardware/VM specifications
- Ensure minimal background processes
- Control database state (fresh state or consistent seed data)
- Document all environment variables and configuration

### Instrumentation Sources

Metrics will be collected from:

1. **Application-level**: Custom instrumentation in benchmark jobs
   - Job execution time (start to finish)
   - Queue wait time (enqueue to start)
   - Error counts

2. **System-level**: OS and process monitoring
   - CPU usage (per-process and system-wide)
   - Memory usage (RSS, heap)
   - I/O statistics

3. **Database-level**: PostgreSQL monitoring
   - Query execution times
   - Connection pool usage
   - Lock waits
   - Transaction counts

4. **Gem-level**: Built-in metrics (if available)
   - Queue depth
   - Worker status
   - Job status counts

### Reporting Approach

Results will be reported as:

- **Summary statistics**: Mean, median, percentiles (p50, p95, p99, p99.9)
- **Time series data**: Metrics over time to show stability
- **Comparative tables**: Side-by-side comparison of SolidQueue vs GoodJob
- **Visualizations**: Charts showing latency distributions, throughput over time, resource usage

### Reproducibility

To ensure results can be reproduced:

- Version pin all dependencies (Ruby, Rails, gems, PostgreSQL)
- Document exact environment setup steps
- Include seed data or generation scripts
- Provide exact commands to run benchmarks
- Store raw metrics data for later analysis

## Alternatives Considered

- **Single-run benchmarks**: Rejected - too much variance, need multiple runs for statistical significance
- **Production-like environment**: Rejected - too many variables, harder to reproduce
- **Containerized environment only**: Considered but not yet decided - may add Docker setup later for easier reproduction
- **External monitoring tools**: Considered but may add complexity; start with built-in tools, add if needed

## Consequences

### Positive

- Consistent methodology enables fair comparison
- Reproducible results increase credibility
- Multiple data sources provide comprehensive view
- Statistical approach accounts for variance

### Negative

- More complex setup required
- Longer benchmark runs (warmup + multiple iterations)
- More data to collect and analyze
- May need to build custom instrumentation

## Open Questions / Follow-ups

- What warmup duration is sufficient? (Need to test and document)
- How many iterations are needed for statistical significance? (Document after initial tests)
- Should we use a specific benchmarking framework? (e.g., benchmark-ips, or custom?)
- How do we handle outliers in the data? (Document analysis approach)
- Should we containerize the benchmark environment? (Separate decision)
- What PostgreSQL version should we target? (Separate decision)
