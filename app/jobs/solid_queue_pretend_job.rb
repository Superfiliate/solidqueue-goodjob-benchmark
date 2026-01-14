class SolidQueuePretendJob < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform(benchmark_run)
    run = benchmark_run.is_a?(BenchmarkRun) ? benchmark_run : BenchmarkRun.find(benchmark_run)
    # No work - this is a placeholder job for benchmarking
    run.update!(run_finished_at: Time.current)
  end
end
