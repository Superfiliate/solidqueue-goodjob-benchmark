class AddSchedulingStartedAtToBenchmarkRuns < ActiveRecord::Migration[8.1]
  def change
    add_column :benchmark_runs, :scheduling_started_at, :datetime
  end
end
