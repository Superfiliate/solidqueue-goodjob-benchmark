# Run in: rails console (production)
require "json"
require "etc"

queue_config = Rails.application.config_for(:queue)
queue_config = queue_config.to_h if queue_config.respond_to?(:to_h)

good_job_config = Rails.application.config.good_job
good_job_config = good_job_config.slice(
  :execution_mode,
  :enable_cron,
  :preserve_job_records,
  :retry_on_unhandled_error
) if good_job_config.respond_to?(:slice)

mem_total_kb = nil
if File.exist?("/proc/meminfo")
  mem_line = File.read("/proc/meminfo").lines.find { |line| line.start_with?("MemTotal:") }
  mem_total_kb = mem_line&.split&.fetch(1, nil)&.to_i
end

env_info = {
  ruby_version: RUBY_VERSION,
  ruby_patchlevel: RUBY_PATCHLEVEL,
  ruby_platform: RUBY_PLATFORM,
  rails_version: Rails.version,
  good_job_version: Gem.loaded_specs["good_job"]&.version&.to_s,
  solid_queue_version: Gem.loaded_specs["solid_queue"]&.version&.to_s,
  postgres_version: ActiveRecord::Base.connection.select_value("SHOW server_version"),
  cpu_count: Etc.nprocessors,
  mem_total_kb: mem_total_kb,
  job_concurrency_env: ENV["JOB_CONCURRENCY"],
  queue_config: queue_config,
  good_job_config: good_job_config
}

puts "=== ENVIRONMENT ==="
puts JSON.pretty_generate(env_info)

scope = BenchmarkRun
  .where.not(scheduling_started_at: nil, scheduling_finished_at: nil, run_finished_at: nil)
  .where("run_finished_at <= ?", 30.seconds.ago)
  .order(:created_at)

puts "=== RUNS_TSV ==="
rows = []
rows << %w[
  id gem scheduling_mode jobs_count created_at scheduling_started_at
  scheduling_finished_at run_finished_at scheduling_progress
  scheduling_duration_s run_duration_s
]

scope.find_each do |run|
  scheduling_duration = run.scheduling_finished_at && run.scheduling_started_at ?
    (run.scheduling_finished_at - run.scheduling_started_at) : nil
  run_duration = run.run_finished_at && run.scheduling_started_at ?
    (run.run_finished_at - run.scheduling_started_at) : nil

  rows << [
    run.id,
    run.gem,
    run.scheduling_mode,
    run.jobs_count,
    run.created_at&.iso8601,
    run.scheduling_started_at&.iso8601,
    run.scheduling_finished_at&.iso8601,
    run.run_finished_at&.iso8601,
    run.scheduling_progress,
    scheduling_duration&.round(3),
    run_duration&.round(3)
  ]
end

puts rows.map { |row| row.map { |v| v.to_s }.join("\t") }.join("\n")
