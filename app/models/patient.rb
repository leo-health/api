class Patient < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :family
  belongs_to :role
  has_many :appointments
  has_many :medications
  has_many :photos
  has_many :vaccines
  has_many :vitals
  has_many :insurances
  has_many :avatars, as: :owner

  validates :first_name, :last_name, :birth_date, :sex, :family, :role, presence: true

  after_commit :upgrade_guardian!, on: :create

  def current_avatar
    avatars.order("created_at DESC").first
  end

  private

  def upgrade_guardian!
    family.primary_parent.try(:upgrade!)
  end
end
