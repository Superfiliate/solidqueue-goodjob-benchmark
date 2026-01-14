# Benchmark Scope and Success Metrics

## Context

Before implementing the benchmark, we need to clearly define:
- What questions we're trying to answer
- What scenarios are in scope
- What success looks like
- What we're explicitly not testing

This decision document establishes the foundation for all benchmark work.

## Decision

### Benchmark Questions

The benchmark will answer:

1. **Performance Comparison**: How do SolidQueue and GoodJob compare in terms of:
   - Job execution latency (p50, p95, p99, p99.9)
   - Throughput (jobs/second)
   - Resource efficiency (CPU, memory)

2. **Scalability**: How do they handle:
   - Increasing concurrency levels
   - Burst traffic patterns
   - Sustained high load

3. **Database Impact**: What is the database load:
   - Query patterns and frequency
   - Connection pool usage
   - Lock contention and deadlocks

4. **Operational Characteristics**: How do they differ in:
   - Queue depth management
   - Error handling and retry behavior
   - Monitoring and observability

### Success Criteria

The benchmark is successful if:

- We can clearly identify performance differences between the two gems
- Results are reproducible and statistically significant
- We can explain the trade-offs and when to use each gem
- The methodology is transparent and can be independently verified

### In Scope

- Standard Rails job execution patterns
- Multiple workload types (CPU-bound, I/O-bound, mixed)
- Various concurrency configurations
- Database-backed job storage (both gems use PostgreSQL)
- Standard Rails application patterns

### Out of Scope

- Distributed job execution across multiple servers (single-server benchmark)
- Custom job middleware or extensions
- Integration with external job monitoring tools
- Production deployment considerations (focus on performance, not ops)
- Job scheduling/retry policy comparisons (unless they affect performance)

## Alternatives Considered

- **Multi-server distributed benchmark**: Rejected as it adds complexity and may not be representative of typical usage
- **Including Sidekiq/Resque**: Rejected to keep scope focused on PostgreSQL-backed solutions
- **Production-like environment**: Rejected in favor of controlled, reproducible test environment

## Consequences

### Positive

- Clear, focused scope makes implementation more straightforward
- Reproducible results will be easier to achieve
- Results will be directly comparable between the two gems

### Negative

- Results may not reflect all production scenarios
- Single-server benchmark may not reveal distributed system issues
- May miss edge cases that occur in complex production environments

## Open Questions / Follow-ups

- What specific job types should we test? (Document in separate decision)
- What concurrency levels are most representative? (Document in separate decision)
- How do we define "statistically significant" results? (Document in technical decision)
- Should we test with different PostgreSQL versions? (Document in technical decision)
