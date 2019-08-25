require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require 'rack/ssl-enforcer'

require "./lib/middleware/health.rb"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Demo
  class Application < Rails::Application
    config.autoload_paths << Rails.root.join('lib')
    Rails.logger = Logger.new(STDOUT)
    config.logger = ActiveSupport::Logger.new("log/#{Rails.env}.log")

    config.middleware.use Middleware::Health
    config.middleware.use ActionDispatch::Cookies
    config.middleware.insert_before 0, Rack::SslEnforcer, ignore: lambda { |request| request.env["HTTP_X_FORWARDED_PROTO"].blank? }, :hsts => true
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end
