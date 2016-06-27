# frozen_string_literal: true
FactoryGirl.define do
  factory :requested_enhancement, traits: %i(audited) do
    association :subject
    association :provider

    message { Faker::Lorem.paragraph }
  end
end
