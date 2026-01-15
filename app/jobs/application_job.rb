class ApplicationJob < ActiveJob::Base
  class ConcurrentRunError < StandardError; end

  retry_on Exception, wait: :polynomially_longer, attempts: 25
  discard_on ActiveJob::DeserializationError
end
