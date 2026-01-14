class GoodJobSchedulingJob < ApplicationJob
  self.queue_adapter = :good_job

  def perform(benchmark_run)
    run = fetch_run(benchmark_run)
    return if run.nil?

    BenchmarkRun.transaction do
      # Enqueue jobs one-by-one to mirror typical production usage.
      run.jobs_count.times do
        GoodJobPretendJob.perform_later(run)
      end

      BenchmarkRun.where(id: run.id).update_all(scheduling_finished_at: Time.current)
    end
  end

  private

  def fetch_run(benchmark_run)
    return benchmark_run if benchmark_run.is_a?(BenchmarkRun)

    BenchmarkRun.find(benchmark_run)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
