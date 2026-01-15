class SolidQueueSchedulingJob < ApplicationJob
  self.queue_adapter = :solid_queue
  discard_on ActiveJob::DeserializationError

  def perform(benchmark_run)
    run = fetch_run(benchmark_run)
    return if run.nil?

    scheduled_at = 10.seconds.from_now
    run.update(created_at: scheduled_at)

    # Enqueue jobs one-by-one to mirror typical production usage.
    run.jobs_count.times do
      SolidQueuePretendJob.set(wait_until: scheduled_at).perform_later(run)
    end

    run.update(scheduling_finished_at: Time.current)
  end

  private

  def fetch_run(benchmark_run)
    return benchmark_run if benchmark_run.is_a?(BenchmarkRun)

    BenchmarkRun.find(benchmark_run)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
