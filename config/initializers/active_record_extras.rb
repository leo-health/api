module ActiveRecordExtras
  module Relation
    extend ActiveSupport::Concern

    module ClassMethods
      def update_or_create!(search, attributes)
        object = find_or_initialize_by({"#{search}": attributes[search]})
        object.update_attributes!(attributes)
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecordExtras::Relation
