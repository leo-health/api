require 'rails_helper'
require 'mandrill_mailer/offline'

describe Survey do
  describe "relations" do
    it{ is_expected.to have_many(:questions) }
    it{ is_expected.to have_many(:user_surveys) }
    it{ is_expected.to have_many(:users).through(:user_surveys) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:private) }
    it { is_expected.to validate_presence_of(:required) }
    it { is_expected.to validate_presence_of(:reason) }
  end
end
