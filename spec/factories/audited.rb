# frozen_string_literal: true

FactoryBot.define do
  trait :audited do
    audit_comment { Faker::Lorem.sentence }
  end
end
