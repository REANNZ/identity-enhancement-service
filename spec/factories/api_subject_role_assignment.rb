# frozen_string_literal: true

FactoryBot.define do
  factory :api_subject_role_assignment, traits: %i[audited] do
    association :api_subject
    association :role
  end
end
