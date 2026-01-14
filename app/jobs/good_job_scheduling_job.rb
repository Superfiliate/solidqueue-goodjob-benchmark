class GoodJobSchedulingJob < ApplicationJob
  self.queue_adapter = :good_job

  def perform(benchmark_run)
    run = benchmark_run.is_a?(BenchmarkRun) ? benchmark_run : BenchmarkRun.find(benchmark_run)

    BenchmarkRun.transaction do
      run.jobs_count.times do
        GoodJobPretendJob.perform_later
      end

      run.update!(scheduling_finished_at: Time.current)
    end
  end
end
