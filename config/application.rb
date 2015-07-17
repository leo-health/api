require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(*Rails.groups)

module Api
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true
    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]
    config.active_job.queue_adapter = :delayed_job
  end
end
