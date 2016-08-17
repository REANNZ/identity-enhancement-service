# frozen_string_literal: true
FactoryGirl.define do
  factory :subject_role_assignment, traits: %i(audited) do
    association :subject
    association :role
  end
end
