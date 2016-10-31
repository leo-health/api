class Choice < ActiveRecord::Base
  belongs_to :question

  validates_presence_of :question, :choice_type
  validates_inclusion_of :choice_type, in: %w(structured unstructured)
end
