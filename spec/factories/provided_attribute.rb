# frozen_string_literal: true

FactoryBot.define do
  factory :provided_attribute, traits: %i(audited) do
    association :permitted_attribute
    association :subject

    name { permitted_attribute.available_attribute.name }
    value { permitted_attribute.available_attribute.value }
  end
end
