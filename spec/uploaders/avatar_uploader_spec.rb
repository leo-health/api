require 'rails_helper'
require 'carrierwave/test/matchers'

describe AvatarUploader do
  include CarrierWave::Test::Matchers

  let(:patient){create(:patient)}
  let(:avatar){Avatar.create(owner: patient)}

  before do
    AvatarUploader.enable_processing = true
    @uploader = AvatarUploader.new(avatar, :avatar)

    File.open(Rails.root.join('spec', 'support', 'Zen-Dog1.jpg')) do |f|
      @uploader.store!(f)
    end
  end

  after do
    AvatarUploader.enable_processing = false
    @uploader.remove!
  end

  context 'the default_large version' do
    it "should scale down a landscape image to be exactly 214 by 214 pixels" do
      expect(@uploader.default_large).to have_dimensions(214, 214)
    end
  end

  context 'the default_medium version' do
    it "should scale down a landscape image to fit within 144 by 144 pixels" do
      @uploader.default_medium.should be_no_larger_than(144, 144)
    end
  end

  context 'the default_small version' do
    it "should scale down a landscape image to fit within 72 by 72 pixels" do
      @uploader.default_small.should be_no_larger_than(72, 72)
    end
  end
end
