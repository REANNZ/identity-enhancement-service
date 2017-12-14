# frozen_string_literal: true

FactoryBot.define do
  factory :requested_enhancement, traits: %i[audited] do
    association :subject
    association :provider

    message { Faker::Lorem.paragraph }
  end
end
