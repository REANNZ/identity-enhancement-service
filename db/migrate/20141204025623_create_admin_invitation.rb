# frozen_string_literal: true
class CreateAdminInvitation < ActiveRecord::Migration
  class Provider < ActiveRecord::Base
    has_many :invitations
    has_many :roles
  end

  class Subject < ActiveRecord::Base
    has_many :subject_role_assignments
  end

  class Invitation < ActiveRecord::Base
    belongs_to :provider
    belongs_to :subject
  end

  class Role < ActiveRecord::Base
    belongs_to :provider
    has_many :permissions
  end

  class Permission < ActiveRecord::Base
    belongs_to :role
  end

  class SubjectRoleAssignment < ActiveRecord::Base
    belongs_to :subject
    belongs_to :role
  end

  def change
    reversible do |dir|
      dir.up do
        transaction do
          p = Provider.create!(name: 'Australian Access Federation',
                               description: '',
                               identifier: 'aaf')

          s = Subject.create!(name: 'Administrator',
                              mail: 'support@aaf.edu.au')

          Invitation.create!(identifier: SecureRandom.urlsafe_base64(19),
                             name: 'Administrator',
                             mail: 'support@aaf.edu.au',
                             expires: 1.week.from_now,
                             provider: p,
                             subject: s)

          r = p.roles.create!(name: 'Super Administrator')
          r.permissions.create(value: '*')

          s.subject_role_assignments.create(role: r)

          say "Invitation path: /invitations/#{Invitation.last.identifier}"
        end
      end
    end
  end
end
