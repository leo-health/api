class Patient < ActiveRecord::Base
  acts_as_paranoid
  include PgSearch
  pg_search_scope(
    :search,
    against: %i( first_name last_name ),
    using: {
        tsearch: { prefix: true },
        trigram: { threshold: 0.3 }
    }
  )

  belongs_to :family
  belongs_to :role
  has_many :appointments
  has_many :medications
  has_many :allergies
  has_many :photos
  has_many :vaccines
  has_many :vitals
  has_many :insurances
  has_many :avatars, as: :owner
  has_many :user_generated_health_records
  has_many :forms

  validates :first_name, :last_name, :birth_date, :sex, :family, :role, presence: true

  after_commit :upgrade_guardian!, :notify_guardian, on: :create

  def current_avatar
    avatars.order("created_at DESC").first
  end

  private

  def notify_guardian
    if sender = User.leo_bot
      family.conversation.messages.create(
          body: "#{first_name.capitalize} has been enrolled successfully",
          type_name: :text,
          sender: sender
      )
    end
  end

  def upgrade_guardian!
    family.primary_guardian.try(:upgrade!)
  end
end
