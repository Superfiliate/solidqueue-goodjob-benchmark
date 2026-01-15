# frozen_string_literal: true

# GoodJob models use the primary database
class GoodJobRecord < ApplicationRecord
  self.abstract_class = true
end
