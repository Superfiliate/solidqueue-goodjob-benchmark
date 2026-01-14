class BenchmarkRun < ApplicationRecord
  enum :gem, { solid_queue: "solid_queue", good_job: "good_job" }, prefix: true

  validates :gem, presence: true
  validates :jobs_count, presence: true, numericality: { greater_than: 0 }

  def completed?
    run_finished_at.present? && run_finished_at <= 5.seconds.ago
  end
end
