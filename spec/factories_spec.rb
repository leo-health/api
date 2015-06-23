require 'rails_helper'

describe "Factory Girl" do
  FactoryGirl.factories.map(&:name).each do |factory_name|
    describe "The #{factory_name} factory" do
      it "is valid" do
        expect(build(factory_name)).to be_valid
      end

      FactoryGirl.factories[factory_name].definition.defined_traits.map(&:name).each do |trait_name|
        context "with trait #{trait_name}" do
          it "is valid" do
            expect(FactoryGirl.build(factory_name, trait_name)).to be_valid
          end
        end
      end
    end
  end
end
