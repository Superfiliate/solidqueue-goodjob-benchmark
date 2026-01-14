class GoodJobPretendJob < ApplicationJob
  self.queue_adapter = :good_job

  def perform
    # No work - this is a placeholder job for benchmarking
  end
end
