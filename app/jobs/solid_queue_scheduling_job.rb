class SolidQueueSchedulingJob < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform(benchmark_run)
    run = benchmark_run.is_a?(BenchmarkRun) ? benchmark_run : BenchmarkRun.find(benchmark_run)

    BenchmarkRun.transaction do
      run.jobs_count.times do
        SolidQueuePretendJob.perform_later
      end

      run.update!(scheduling_finished_at: Time.current)
    end
  end
end
