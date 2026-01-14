class SolidQueuePretendJob < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform
    # No work - this is a placeholder job for benchmarking
  end
end
