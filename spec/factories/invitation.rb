# frozen_string_literal: true

FactoryBot.define do
  factory :invitation, traits: %i[audited] do
    association :provider
    association :subject, :incomplete

    identifier { SecureRandom.urlsafe_base64(19) }
    name { subject.name }
    mail { subject.mail }
    expires { 1.year.from_now.to_s(:db) }
    last_sent_at { Time.zone.now.to_s(:db) }
  end
end
