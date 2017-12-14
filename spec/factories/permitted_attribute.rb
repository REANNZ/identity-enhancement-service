# frozen_string_literal: true

FactoryBot.define do
  factory :permitted_attribute, traits: %i[audited] do
    association :available_attribute
    association :provider
  end
end
