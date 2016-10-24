class Choice < ActiveRecord::Base
  belongs_to :question

  validates_presence_of :question, :choice_type
end
