require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(*Rails.groups)

module Api
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true
    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]
    config.active_job.queue_adapter = :delayed_job

    if Rails.env.test?
      log_level = "INFO"
      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger.const_get(log_level)
      config.log_level = log_level
    end
  end
end
