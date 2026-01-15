class SolidQueueSchedulingJob < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform(benchmark_run)
    BenchmarkRun.with_advisory_lock!(0, timeout_seconds: 10) do
      if BenchmarkRun.running.where.not(id: benchmark_run.id).exists?
        raise ApplicationJob::ConcurrentRunError, "Another benchmark run is already running."
      end

      benchmark_run.update!(scheduling_started_at: Time.current)

      benchmark_run.jobs_count.times.with_index do |index|
        # Compute each delay independently to avoid using a stale timestamp.
        SolidQueuePretendJob.set(wait_until: 10.seconds.from_now).perform_later(benchmark_run)

        # Update progress every 100 iterations or on the last iteration
        if (index + 1) % 100 == 0 || index + 1 == benchmark_run.jobs_count
          benchmark_run.update_column(:scheduling_progress, index + 1)
        end
      end

      # Scheduling finishes when the enqueue loop completes.
      benchmark_run.update!(scheduling_finished_at: Time.current)
    end
  end
end
