# frozen_string_literal: true
FactoryGirl.define do
  factory :available_attribute, traits: %i(audited) do
    name 'eduPersonEntitlement'
    value { "urn:mace:aaf.edu.au:ide:#{Faker::Lorem.words(7).join(':')}" }
    description { Faker::Lorem.sentence }
  end
end
