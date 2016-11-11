class Survey < ActiveRecord::Base
  has_many :questions
  has_many :user_surveys
  has_many :users, through: :user_surveys
  validates_presence_of :name, :private, :required, :reason, :survey_type, :display_name
  validates_inclusion_of :survey_type, in: %w(clinical feedback tracking)

  def mchat?
    name.to_sym == :MCHAT24 || name.to_sym == :MCHAT18
  end
end
