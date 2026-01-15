class HomeController < ApplicationController
  def index
    @solid_queue_runs = BenchmarkRun.gem_solid_queue.order(scheduling_mode: :asc, jobs_count: :desc, created_at: :desc)
    @good_job_runs = BenchmarkRun.gem_good_job.order(scheduling_mode: :asc, jobs_count: :desc, created_at: :desc)
    @chart_data = chart_data
  end

  private

  def chart_data
    all_runs = BenchmarkRun.all.select { |run| run.run_duration.present? }

    {
      solidQueueBulk: serialize_runs(all_runs.select { |r| r.gem_solid_queue? && r.scheduling_mode_in_bulk? }),
      solidQueueOneByOne: serialize_runs(all_runs.select { |r| r.gem_solid_queue? && r.scheduling_mode_one_by_one? }),
      goodJobBulk: serialize_runs(all_runs.select { |r| r.gem_good_job? && r.scheduling_mode_in_bulk? }),
      goodJobOneByOne: serialize_runs(all_runs.select { |r| r.gem_good_job? && r.scheduling_mode_one_by_one? }),
    }
  end

  def serialize_runs(runs)
    runs.map { |run| { x: run.jobs_count, y: run.run_duration.to_i } }
  end
end
