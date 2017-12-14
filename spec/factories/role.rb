# frozen_string_literal: true

FactoryBot.define do
  factory :role, traits: %i(audited) do
    association :provider
    name { Faker::Lorem.sentence }
  end
end
