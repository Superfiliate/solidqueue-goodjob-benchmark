class GoodJobPretendJob < ApplicationJob
  self.queue_adapter = :good_job

  def perform(benchmark_run)
    # No work - this is a placeholder job for benchmarking
    benchmark_run.update!(run_finished_at: Time.current)
  end
end
