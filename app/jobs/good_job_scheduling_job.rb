class GoodJobSchedulingJob < ApplicationJob
  self.queue_adapter = :good_job

  def perform(benchmark_run)
    BenchmarkRun.with_advisory_lock!(0, timeout_seconds: 10) do
      if BenchmarkRun.running.where.not(id: benchmark_run.id).exists?
        raise ApplicationJob::ConcurrentRunError, "Another benchmark run is already running."
      end

      benchmark_run.update!(scheduling_started_at: Time.current)

      benchmark_run.jobs_count.times do
        # Compute each delay independently to avoid using a stale timestamp.
        GoodJobPretendJob.set(wait_until: 10.seconds.from_now).perform_later(benchmark_run)
      end

      # Scheduling finishes when the enqueue loop completes.
      benchmark_run.update!(scheduling_finished_at: Time.current)
    end
  end
end
