# frozen_string_literal: true

FactoryGirl.define do
  factory :provider, traits: %i(audited) do
    name { Faker::Company.name }
    description { Faker::Lorem.sentence }
    identifier do
      [name.gsub(/[^\w-]+/, '-'), Faker::Lorem.word].join('-')[0..39]
    end
  end
end
