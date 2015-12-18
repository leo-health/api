CarrierWave.configure do |config|
  if Rails.env.test? || Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false
    config.root = "#{Rails.root}/tmp"
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
