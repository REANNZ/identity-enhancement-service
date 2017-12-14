# frozen_string_literal: true

unless ENV['AAF_DEV'].to_i == 1
  $stderr.puts <<-EOF

  This is a destructive action, intended only for use in development
  environments where you wish to replace ALL data with generated sample data.

  If this is what you want, set the AAF_DEV environment variable to 1 before
  attempting to seed your database.

  EOF
  raise('Not proceeding, missing AAF_DEV=1 environment variable')
end

require 'faker'
require 'factory_girl'

ActiveRecord::Base.transaction do
  FactoryBot.lint
  raise(ActiveRecord::Rollback)
end

include FactoryBot::Syntax::Methods

invitation_code = SecureRandom.urlsafe_base64(19)
ActiveRecord::Base.transaction do
  [
    ProvidedAttribute, PermittedAttribute, AvailableAttribute,
    APISubjectRoleAssignment, APISubject,
    SubjectRoleAssignment, Subject, Invitation,
    Provider, Role, Permission
  ].each(&:delete_all)

  i = 0

  count = lambda do |a|
    i += Array(a).length
    print("\rCreating Objects: #{i}\e[0K")
  end

  FactoryBot.define { after(:create) { count.call(1) } }

  aaf = create(:provider, name: 'Australian Access Federation')
  admin = create(:role, name: 'Super Administrator', provider: aaf)
  create(:permission, role: admin, value: '*')

  admin_user = create(:subject, name: 'Administrator', mail: 'root@example.com')

  create(:subject_role_assignment, subject: admin_user, role: admin)
  create(:invitation, subject: admin_user, provider: aaf,
                      identifier: invitation_code)

  create_list(:provider, 100).each do |provider|
    provider.create_default_roles
    count.call(provider.roles + provider.roles.flat_map(&:permissions))
  end

  providers = Provider.includes(roles: :permissions).all

  providers.each do |provider|
    create_list(:requested_enhancement, (1..5).to_a.sample, provider: provider)
  end

  create_list(:subject, 500).each do |subject|
    if rand < 0.2
      subject.without_auditing do
        subject.update_attributes!(shared_token: nil, targeted_id: nil,
                                   complete: false)
      end

      create(:invitation, subject: subject)
    end

    while rand < 0.7
      role = providers.sample.roles.to_a.sample
      next if role.nil? || subject.roles.include?(role)
      create(:subject_role_assignment, subject: subject, role: role)
    end
  end
end

puts
puts "To gain admin privileges, visit: /invitations/#{invitation_code}"
