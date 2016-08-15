require "rails_helper"

describe "GenericHelper" do
  describe "self.closest_item" do
    it "should return the item from the array that is closest to the value" do
      expect(GenericHelper.closest_item(5,[0,1,2,3,4,5])).to eq(5)
      expect(GenericHelper.closest_item(3.5,[0,1,2,3,4,5])).to eq(4)
      expect(GenericHelper.closest_item(3.6,[0,1,2,3,4,5])).to eq(4)
      expect(GenericHelper.closest_item(3.4,[0,1,2,3,4,5])).to eq(3)
      expect(GenericHelper.closest_item(10,[0,1,2,3,4,5])).to eq(5)
      expect(GenericHelper.closest_item(3.5,[])).to eq(nil)
      expect(GenericHelper.closest_item(nil,[0,1,2,3,4,5])).to eq(nil)
      expect(GenericHelper.closest_item(4.6,[1,2,3,4,5])).to eq(5)
      expect(GenericHelper.closest_item(3.6,[1,2,3,4,5])).to eq(4)
    end
  end
end
