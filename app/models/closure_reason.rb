class ClosureReason < ActiveRecord::Base
  validates :reason_order, :short_description, :long_description, presence: true
end
