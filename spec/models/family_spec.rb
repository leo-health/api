# == Schema Information
#
# Table name: families
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe Family, type: :model do
  subject { create(:family_with_members) }

  describe '#parents' do
  	it 'returns all the family members that are parents' do 
  	 expect(subject.parents.count).to eq(2)
    end
  end

  describe '#children'do 
  	it 'returns all the fmaily members that are children' do 
  	 expect(subject.children.count).to eq(3)
    end
  end

  describe '#guardians' do
  	it 'returns all the family members that are guardians'do 
  	 expect(subject.guardians.count).to eq(0)
    end
  end
end
