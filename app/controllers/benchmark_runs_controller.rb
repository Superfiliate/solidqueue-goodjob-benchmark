class BenchmarkRunsController < ApplicationController
  def create
    @benchmark_run = BenchmarkRun.new(benchmark_run_params)

    if @benchmark_run.save
      redirect_to root_path, notice: "Benchmark run created successfully."
    else
      redirect_to root_path, alert: "Failed to create benchmark run: #{@benchmark_run.errors.full_messages.join(', ')}"
    end
  end

  private

  def benchmark_run_params
    params.require(:benchmark_run).permit(:gem, :jobs_count)
  end
end
