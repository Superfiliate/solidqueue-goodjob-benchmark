class AddSchedulingModeToBenchmarkRuns < ActiveRecord::Migration[8.1]
  def change
    add_column :benchmark_runs, :scheduling_mode, :string, default: "one_by_one", null: false
  end
end
