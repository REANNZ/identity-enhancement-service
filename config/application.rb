# frozen_string_literal: true
require File.expand_path('../boot', __FILE__)

require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module IdentityEnhancementService
  class Application < Rails::Application
    config.autoload_paths << File.join(config.root, 'lib')

    config.rapid_rack.receiver = 'Authentication::SubjectReceiver'
    config.rapid_rack.error_handler = 'Authentication::ErrorHandler'
  end
end
