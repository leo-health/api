APNS_CONFIG = YAML.load_file("#{::Rails.root}/config/apns.yml")[::Rails.env]
