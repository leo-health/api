require 'rails_helper'

describe Family, type: :model do
  subject { create(:family_with_members) }

  describe '#children'do
  	it 'returns all the fmaily members that are children' do
  	 expect(subject.children.count).to eq(3)
    end
  end

  describe '#guardians' do
  	it 'returns all the family members that are guardians'do
  	 expect(subject.guardians.count).to eq(2)
    end
  end
end
