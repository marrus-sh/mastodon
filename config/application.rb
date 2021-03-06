require_relative 'boot'

require 'rails/all'

require_relative '../app/lib/exceptions'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Railtie.load

module Mastodon
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.available_locales = [:en, :de, :es, :pt, :fr, :hu, :uk]
    config.i18n.default_locale    = :en

    # config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    # config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    config.active_job.queue_adapter = :sidekiq

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins  '*'

        resource '/api/*',       headers: :any, methods: [:post, :put, :delete, :get, :options], credentials: false
        resource '/oauth/token', headers: :any, methods: [:post], credentials: false
      end
    end

    config.middleware.use Rack::Attack
    config.middleware.use Rack::Deflater

    config.browserify_rails.commandline_options = '--transform [ babelify --presets [ es2015 react ] ] --extension=".jsx"'

    config.to_prepare do
      Doorkeeper::AuthorizationsController.layout 'public'
      Doorkeeper::AuthorizedApplicationsController.layout 'admin'
      Doorkeeper::Application.send :include, ApplicationExtension
    end

    config.action_dispatch.default_headers = {
      'Server'                 => 'Ardipithecus',
      'X-Frame-Options'        => 'DENY',
      'X-Content-Type-Options' => 'nosniff',
      'X-XSS-Protection'       => '1; mode=block',
    }
  end
end
