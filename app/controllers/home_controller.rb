class HomeController < ApplicationController
  def index
    @solid_queue_runs = BenchmarkRun.gem_solid_queue.order(created_at: :desc)
    @good_job_runs = BenchmarkRun.gem_good_job.order(created_at: :desc)
  end
end
