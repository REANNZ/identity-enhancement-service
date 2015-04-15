FactoryGirl.define do
  factory :invitation, traits: %i(audited) do
    association :provider
    association :subject, :incomplete

    identifier { SecureRandom.urlsafe_base64(19) }
    name { Faker::Name.name }
    mail { Faker::Internet.email(name) }
    expires { 1.year.from_now.to_s(:db) }
    last_sent_at { Time.now.to_s(:db) }
  end
end
