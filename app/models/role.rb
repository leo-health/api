class Role < ActiveRecord::Base
  has_many :users
  scope :staff_roles, -> { where(name: %i(financial clinical_support customer_service clinical operational)) }
  scope :clinical_staff_roles, -> { where(name: %i(clinical_support customer_service clinical)) }
  scope :guardian_roles, -> { where(name: :guardian)}
  scope :provider_roles, -> { where(name: :clinical)}
  validates :name, presence: true
  validates_uniqueness_of :name

  class << self
    private
    def role_by_name
      Role.find_by(name: __callee__)
    end

    roles = Role.all.map(&:name) | [:financial, :clinical_support, :customer_service, :guardian, :clinical, :bot, :operational]
    roles.each do |role|
      alias_method role, :role_by_name
      public role
    end
  end
end
