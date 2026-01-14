class SolidQueuePretendJob < ApplicationJob
  self.queue_adapter = :solid_queue

  class SchedulingNotFinishedError < StandardError; end
  retry_on SchedulingNotFinishedError,
           wait: :polynomially_longer,
           attempts: 15

  def perform(benchmark_run)
    run = fetch_run(benchmark_run)
    return if run.nil?
    raise SchedulingNotFinishedError, "Scheduling not finished for BenchmarkRun #{run.id}" if run.scheduling_finished_at.nil?
    # No work - this is a placeholder job for benchmarking
    BenchmarkRun.where(id: run.id).update_all(run_finished_at: Time.current)
  end

  private

  def fetch_run(benchmark_run)
    return benchmark_run if benchmark_run.is_a?(BenchmarkRun)

    BenchmarkRun.find(benchmark_run)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
