class BenchmarkRunsController < ApplicationController
  def create
    @benchmark_run = BenchmarkRun.new(benchmark_run_params)

    if @benchmark_run.save
      enqueue_scheduling_job(@benchmark_run)
      redirect_to root_path, notice: "Benchmark run created successfully."
    else
      redirect_to root_path, alert: "Failed to create benchmark run: #{@benchmark_run.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    benchmark_run = BenchmarkRun.find(params[:id])
    benchmark_run.destroy
    redirect_to root_path, notice: "Benchmark run deleted."
  end

  private

  def enqueue_scheduling_job(benchmark_run)
    case benchmark_run.gem
    when "solid_queue"
      SolidQueueSchedulingJob.perform_later(benchmark_run)
    when "good_job"
      GoodJobSchedulingJob.perform_later(benchmark_run)
    end
  end

  def benchmark_run_params
    params.require(:benchmark_run).permit(:gem, :jobs_count, :scheduling_mode)
  end
end
