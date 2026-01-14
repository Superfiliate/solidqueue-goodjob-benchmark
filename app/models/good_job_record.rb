# frozen_string_literal: true

# GoodJob models connect to the queue database
class GoodJobRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :queue, reading: :queue }
end
