class Role < ActiveRecord::Base
  has_many :users
  has_many :patients

  validates :name, presence: true
  validates_uniqueness_of :name

  def self.staff
    where(name: [:financial, :clinical_support, :customer_service, :clinical, :operational])
  end

  def self.clinical_staff
    where(name: [:clinical_support, :customer_service, :clinical])
  end

  def self.guardian
    find_by(name: :guardian)
  end
end


describe '.clinical_staff' do
  it "should return all clinical staff roles" do

  end
end
