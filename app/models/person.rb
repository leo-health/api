class Person < ActiveRecord::Base
# Currently not used as an actual DB record
# ????: How should this data be normalized?
  def self.writable_column_names
    # Is there a better way to get these values? column_names returns too much
    [:title, :first_name, :middle_initial, :last_name, :suffix, :sex, :practice_id, :email, :avatar]
  end
end
