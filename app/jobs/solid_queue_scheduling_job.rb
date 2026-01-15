class SolidQueueSchedulingJob < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform(benchmark_run)
    BenchmarkRun.with_advisory_lock!(0, timeout_seconds: 10) do
      if BenchmarkRun.running.where.not(id: benchmark_run.id).exists?
        raise ApplicationJob::ConcurrentRunError, "Another benchmark run is already running."
      end

      benchmark_run.update!(scheduling_started_at: Time.current)

      if benchmark_run.scheduling_mode == "in_bulk"
        schedule_in_bulk(benchmark_run)
      else
        schedule_one_by_one(benchmark_run)
      end

      # Scheduling finishes when the enqueue loop completes.
      benchmark_run.update!(scheduling_finished_at: Time.current)
    end
  end

  private

  def schedule_one_by_one(benchmark_run)
    benchmark_run.jobs_count.times.with_index do |index|
      # Compute each delay independently to avoid using a stale timestamp.
      SolidQueuePretendJob.set(wait_until: 10.seconds.from_now).perform_later(benchmark_run)

      # Update progress every 100 iterations or on the last iteration
      if (index + 1) % 100 == 0 || index + 1 == benchmark_run.jobs_count
        benchmark_run.update_column(:scheduling_progress, index + 1)
      end
    end
  end

  def schedule_in_bulk(benchmark_run)
    batch_size = 1000
    total_batches = (benchmark_run.jobs_count.to_f / batch_size).ceil

    total_batches.times do |batch_index|
      batch_start = batch_index * batch_size
      batch_end = [batch_start + batch_size - 1, benchmark_run.jobs_count - 1].min
      batch_count = batch_end - batch_start + 1

      job_instances = batch_count.times.map do
        SolidQueuePretendJob.new(benchmark_run)
      end

      ActiveJob.perform_all_later(job_instances)

      # Update progress after each batch
      progress = [batch_end + 1, benchmark_run.jobs_count].min
      benchmark_run.update_column(:scheduling_progress, progress)
    end
  end
end
