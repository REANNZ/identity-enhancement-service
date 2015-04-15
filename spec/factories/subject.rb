FactoryGirl.define do
  factory :subject, traits: %i(audited) do
    name { Faker::Name.name }
    mail { Faker::Internet.email(name) }
    shared_token { SecureRandom.urlsafe_base64(16) }
    targeted_id do
      "https://rapid.example.com!https://ide.example.com!#{SecureRandom.hex}"
    end
    complete true

    trait :authorized do
      transient { permission '*' }

      after(:create) do |subject, attrs|
        perm = create(:permission, value: attrs.permission)
        create(:subject_role_assignment, role: perm.role, subject: subject)
      end
    end

    trait :incomplete do
      shared_token nil
      targeted_id nil
      complete false
    end
  end
end
