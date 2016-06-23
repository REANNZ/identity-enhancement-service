# frozen_string_literal: true
require 'mail'

Rails.application.configure do
  app_config = YAML.load_file(Rails.root.join('config/ide_service.yml'))
  config.ide_service = OpenStruct.new(app_config).tap do |c|
    c.mail.symbolize_keys!
  end

  mail_config = config.ide_service.mail
  Mail.defaults { delivery_method :smtp, mail_config }

  if Rails.env.test?
    config.ide_service = OpenStruct.new
    config.ide_service.mail = OpenStruct.new(from: 'noreply@example.com')
    config.ide_service.provider_prefix = 'urn:x-aaf:dev:ide:rspec'

    Mail.defaults { delivery_method :test }
  end
end
