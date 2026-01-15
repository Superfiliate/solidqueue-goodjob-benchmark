class AddSchedulingProgressToBenchmarkRuns < ActiveRecord::Migration[8.1]
  def change
    add_column :benchmark_runs, :scheduling_progress, :integer, default: 0, null: false

    # Migrate existing data
    # Records with scheduling_finished_at filled should have scheduling_progress = jobs_count
    # Records without scheduling_finished_at should keep scheduling_progress = 0 (default)
    BenchmarkRun.where.not(scheduling_finished_at: nil)
      .update_all("scheduling_progress = jobs_count")
  end
end
