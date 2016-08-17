# frozen_string_literal: true
FactoryGirl.define do
  factory :provisioned_subject do
    association :subject
    association :provider

    expires_at nil
  end
end
