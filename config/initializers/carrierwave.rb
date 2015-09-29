if Rails.env.test? || Rails.env.cucumber?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end

  AvatarUploader

  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?
    klass.class_eval do
      def cache_dir
        "#{Rails.root}/spec/support/test/tmp"
      end

      def store_dir
        "#{Rails.root}/spec/support/test/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end
    end
  end
end
