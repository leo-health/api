require 'rails_helper'

RSpec.describe ClosureNote, type: :model do
  it{ is_expected.to belong_to(:conversation) }
  it{ is_expected.to belong_to(:closed_by).class_name('User') }

  it { is_expected.to validate_presence_of(:closed_by) }
  it { is_expected.to validate_presence_of(:conversation) }

  describe "callbacks" do
    let(:closure_note){ create(:closure_note) }

    it { expect(closure_note).to callback(:broadcast_closure_note).after(:commit).on(:create) }
  end
end
