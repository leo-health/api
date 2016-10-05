class LinkPreview < ActiveRecord::Base
  acts_as_paranoid

  has_many :user_link_previews, dependent: :destroy
  has_many :users, through: :user_link_previews
  mount_uploader :icon, CardIconUploader

  validates_integrity_of  :icon
  validates_processing_of :icon
  validates :title, :body, :tint_color_hex, presence: true

  def self.ages_for_milestone_content
    where(category: :milestone_content)
    .order(:age_of_patient_in_months)
    .pluck(:age_of_patient_in_months)
  end

  def self.milestone_index_for_age(age)
    ages = ages_for_milestone_content
    return nil if ages.size == 0
    return ages.count if ages.last + 12 < age # last milestone should only be valid for 12 months

    closest_milestone_age = GenericHelper.closest_item(age, ages)
    i = ages.index(closest_milestone_age) #closest milestone
    i -= closest_milestone_age > age ? 1 : 0 # current milestone
    return nil if i < 0 # haven't yet reached a milestone
    i
  end

  def self.milestone_content_for_age(milestone_age)
    where(
      age_of_patient_in_months: milestone_age,
      category: :milestone_content
    )
  end

  def send_to(users, **options)
    _users = users.respond_to?(:map) ? users : [users]
    _users.map do |u|
      UserLinkPreview.create(
        user: u,
        owner: u,
        link_preview: self,
        **options
      )
    end
  end

  def send_to_with_n_day_expiry(users, n_days, **options)
    send_to(users, options.reverse_merge(dismissed_at: n_days.days.from_now))
  end
end
