# frozen_string_literal: true

json.providers @providers do |provider|
  json.name provider.name
  json.identifier provider.full_identifier
end
