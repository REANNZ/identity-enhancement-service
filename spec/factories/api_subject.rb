FactoryGirl.define do
  factory :api_subject, traits: %i(audited) do
    association :provider
    x509_cn { SecureRandom.urlsafe_base64 }
    name { Faker::Company.name }
    description { Faker::Company.bs }
    contact_name { Faker::Name.name }
    mail { Faker::Internet.email(contact_name) }

    trait :authorized do
      transient { permission '*' }

      after(:create) do |api_subject, attrs|
        perm = create(:permission, value: attrs.permission)
        create(:api_subject_role_assignment, role: perm.role,
                                             api_subject: api_subject)
      end
    end
  end
end
