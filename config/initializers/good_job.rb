# frozen_string_literal: true

# Configure GoodJob to use the queue database via GoodJobRecord
Rails.application.config.good_job = {
  execution_mode: :external,
  enable_cron: false,
  preserve_job_records: true,
  retry_on_unhandled_error: false,
  on_thread_error: ->(exception) { Rails.error.report(exception) }
}

# Set GoodJob to use our custom record class that connects to the queue database
GoodJob.active_record_parent_class = "GoodJobRecord"
