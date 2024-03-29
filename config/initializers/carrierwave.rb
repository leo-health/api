CarrierWave.configure do |config|
  if Rails.env.test? || Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false

    AvatarUploader
    MessageUploader
    FormUploader

    CarrierWave::Uploader::Base.descendants.each do |klass|
      next if klass.anonymous?
      klass.class_eval do
        def cache_dir
          "#{Rails.root}/spec/support/uploads/tmp"
        end

        def store_dir
          "#{Rails.root}/spec/support/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
        end
      end
    end
  else
    config.storage = :aws
  end

  config.aws_credentials = {
    region: ENV['CARRIERWAVE_REGION']
  }

  if Rails.env.development?
    config.aws_credentials[:access_key_id] = ENV['CARRIERWAVE_ACCESS_KEY_ID']
    config.aws_credentials[:secret_access_key] = ENV['CARRIERWAVE_SECRET_ACCESS_KEY']
  end

  config.root = Rails.root.join 'tmp'
  config.aws_authenticated_url_expiration = 60 * 15
  config.aws_bucket = ENV['CARRIERWAVE_AWS_BUCKET']
end
