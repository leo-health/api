require 'fog/aws'

CarrierWave.configure do |config|
  config.fog_credentials = {
    provider:              'AWS',
    aws_access_key_id:     'AKIAIZJEJH6F6OQL43XQ',
    aws_secret_access_key: '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',
    region:                'us-east-1'
  }

  if Rails.env.test? || Rails.env.cucumber?
    config.storage           = :file
    config.enable_processing = false
    config.root              = "#{Rails.root}/tmp"
  else
    config.storage = :fog
  end

  config.fog_directory  = 'leo-photos-development'
end
