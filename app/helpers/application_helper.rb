# frozen_string_literal: true

module ApplicationHelper
  include Lipstick::Helpers::LayoutHelper
  include Lipstick::Helpers::NavHelper
  include Lipstick::Helpers::FormHelper

  def environment_string
    Rails.application.config.ide_service.environment_string
  end

  def markdown_to_html(input)
    # rubocop:disable Rails/OutputSafety
    Kramdown::Document.new(input).to_html.html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def date_string(timestamp)
    timestamp.strftime('%d/%m/%Y')
  end

  def application_version
    '1.1.0'
  end
end
