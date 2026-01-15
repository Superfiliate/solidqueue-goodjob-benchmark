class AddSchedulingProgressToBenchmarkRuns < ActiveRecord::Migration[8.1]
  def change
    add_column :benchmark_runs, :scheduling_progress, :integer, default: 0, null: false

    # Migrate existing data
    # Records with scheduling_finished_at filled should have scheduling_progress = jobs_count
    # Records without scheduling_finished_at should keep scheduling_progress = 0 (default)
    execute <<-SQL
      UPDATE benchmark_runs
      SET scheduling_progress = jobs_count
      WHERE scheduling_finished_at IS NOT NULL
    SQL
  end
end
