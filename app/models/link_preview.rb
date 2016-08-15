class LinkPreview < ActiveRecord::Base
  acts_as_paranoid

  has_many :user_link_previews, as: :card
  has_many :users, through: :user_link_previews
  mount_uploader :icon, CardIconUploader
  validates_integrity_of  :icon
  validates_processing_of :icon

  validates :title, :body, :tint_color_hex, presence: true

  AGES_FOR_MILESTONE_CONTENT = [
    0.5,
    1,
    2,
    3,
    4,
    5,
    6,
    9,
    12,
    15,
    18,
    24,
    30,
    36,
    48,
    60,
    72,
    84,
    96,
    108,
    120,
    132,
    144,
    168,
    180,
    216,
    228,
    264
  ]

end
