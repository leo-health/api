module ActiveRecordExtras
  module Relation
    extend ActiveSupport::Concern

    module ClassMethods
      def update_or_create!(search, attributes)
        search_terms = search.respond_to?(:reduce) ? search : [search]
        search_attrs = search_terms.reduce({}) { |memo, term| memo[term] = attributes[term]; memo }
        object = find_or_initialize_by(search_attrs)
        object.update_attributes!(attributes)
        object
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecordExtras::Relation
