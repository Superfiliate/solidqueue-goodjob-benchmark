class CleanupFinishedJobs < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      DELETE FROM good_job_executions
      USING good_jobs
      WHERE good_job_executions.active_job_id = good_jobs.active_job_id
        AND good_jobs.finished_at IS NOT NULL
    SQL

    execute <<~SQL
      DELETE FROM good_jobs
      WHERE finished_at IS NOT NULL
    SQL

    execute <<~SQL
      DELETE FROM solid_queue_jobs
      WHERE finished_at IS NOT NULL
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
