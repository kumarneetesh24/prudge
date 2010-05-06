# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here

  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  config.cache_store = :mem_cache_store, '127.0.0.1:11211', { :namespace => 'coder' }

  config.action_controller.session_store = :mem_cache_store

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  config.active_record.observers = :user_observer
  config.action_controller.session = {
    :session_key => '_coder_session',
    :secret      => '4dfcafege5e3f536df7a3fa4db76f5a8070d9d508864b876cabe7d79a773f5bf11088849b897a8c98a38c6ce6he9f92ba79b386dadd2be5e1efefe8f83f4c7m'
  }

end
