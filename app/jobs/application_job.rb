class ApplicationJob < ActiveJob::Base
  class ConcurrentRunError < StandardError; end

  discard_on ActiveJob::DeserializationError
  retry_on Exception, wait: :polynomially_longer, attempts: 25
end
