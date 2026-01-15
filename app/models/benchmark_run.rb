class BenchmarkRun < ApplicationRecord
  enum :gem, { solid_queue: "solid_queue", good_job: "good_job" }, prefix: true

  validates :gem, presence: true
  validates :jobs_count, presence: true, numericality: { greater_than: 0 }

  scope :running, lambda {
    where.not(scheduling_started_at: nil)
      .where("run_finished_at IS NULL OR run_finished_at > ?", 30.seconds.ago)
  }

  def completed?
    run_finished_at.present? && run_finished_at <= 30.seconds.ago
  end

  def scheduling_duration
    return if scheduling_started_at.blank? || scheduling_finished_at.blank?

    scheduling_finished_at - scheduling_started_at
  end

  def run_duration
    return if scheduling_started_at.blank? || run_finished_at.blank? || !completed?
    run_finished_at - scheduling_started_at
  end
end
