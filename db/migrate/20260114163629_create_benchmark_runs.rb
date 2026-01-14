class CreateBenchmarkRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :benchmark_runs do |t|
      t.string :gem, null: false
      t.integer :jobs_count, null: false
      t.datetime :scheduling_finished_at
      t.datetime :run_finished_at

      t.timestamps
    end

    add_index :benchmark_runs, :gem
    add_index :benchmark_runs, :created_at
  end
end
