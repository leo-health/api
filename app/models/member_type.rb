class MemberType < ActiveRecord::Base
  class << self
    private
    def enum_by_name
      MemberType.find_by(name: __callee__)
    end

    # ????: replacing MemberType with self causes NoMethodError for .all - no idea why
    (MemberType.all.map(&:name) | [:incomplete, :delinquent, :member, :exempted]).each do |type|
      alias_method type, :enum_by_name
      public type
    end
  end
end
