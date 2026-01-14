# SolidQueue vs GoodJob Performance Benchmark

## Purpose

This project performs a comprehensive performance benchmark comparing [SolidQueue](https://github.com/rails/solid_queue) and [GoodJob](https://github.com/bensheldon/good_job) gems on a Rails application.

## Current Status

**Documentation scaffolding only** - No application implementation exists yet. This project follows a spec-driven, domain-driven design approach where decisions and specifications are documented in the `context/` folder before implementation begins.

## Benchmark Goals

The benchmark aims to answer:

- Which gem performs better under various workload conditions?
- What are the trade-offs between SolidQueue and GoodJob?
- How do they compare in terms of latency, throughput, resource usage, and scalability?
- Which gem is more suitable for different use cases?

## Metrics

Initial metrics to measure (subject to refinement via decision documents):

- **Latency**: Job execution time (p50, p95, p99)
- **Throughput**: Jobs processed per second
- **Resource Usage**: CPU, memory consumption
- **Database Load**: Query patterns, connection pool usage, lock contention
- **Queue Depth**: Number of pending jobs over time
- **Tail Latencies**: Extreme percentiles (p99.9, p99.99)
- **Error Rates**: Failed job rates under load

## Workloads

High-level workload scenarios to simulate (detailed specifications in `context/`):

- Different job types (CPU-bound, I/O-bound, mixed)
- Various concurrency levels
- Burst vs steady-state traffic patterns
- Different queue priorities and scheduling strategies

## Design Approach

This project follows **spec-driven development** and **domain-driven design** principles:

- **Decisions are documented first** in the `context/` folder before implementation
- **Feature decisions** capture what we're building and why
- **Technical decisions** capture how we're building it
- All assumptions and constraints are explicit and discoverable

## Using the Context Folder

The `context/` folder contains all decision documents and specifications. To discover relevant context:

1. **List files** in `context/features/` and `context/technical/`
2. **Read relevant files** based on descriptive filenames
3. **Create new files** when making new decisions (see `context/README.md` for format)

**Important**: There is no index file. Always list the directory to discover what exists.

## Next Steps

1. Review and refine decision documents in `context/`
2. Document benchmark scenarios and success criteria
3. Design the benchmark harness and instrumentation
4. Implement the Rails application and benchmark suite
