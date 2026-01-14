class BenchmarkRun < ApplicationRecord
  enum :gem, { solid_queue: "solid_queue", good_job: "good_job" }, prefix: true

  validates :gem, presence: true
  validates :jobs_count, presence: true, numericality: { greater_than: 0 }

  def completed?
    run_finished_at.present? && run_finished_at <= 5.seconds.ago
  end

  def scheduling_duration
    return if scheduling_finished_at.blank?

    scheduling_finished_at - created_at
  end

  def run_duration
    return if run_finished_at.blank? || run_finished_at > 5.seconds.ago
    return if scheduling_finished_at.blank?

    run_finished_at - scheduling_finished_at
  end
end
