class ClosureReason < ActiveRecord::Base
  validates :order, :short_description, :long_description, presence: true
end
