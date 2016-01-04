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

  config.aws_bucket = 'leo-photos-development'
  config.aws_acl    = 'public-read'

  config.aws_credentials = {
      access_key_id:     'AKIAIZJEJH6F6OQL43XQ',
      secret_access_key: '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',
      region:            'us-east-1'
  }
end
