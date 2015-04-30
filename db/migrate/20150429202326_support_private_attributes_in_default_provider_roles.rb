class SupportPrivateAttributesInDefaultProviderRoles < ActiveRecord::Migration
  def change
    transaction do
      reversible do |dir|
        dir.up do
          execute %(
            insert into permissions
              (role_id, value, created_at, updated_at)
            select
              id,
              concat('providers:', provider_id, ':attributes:read'),
              now(),
              now()
            from roles
            where name = 'API Read Only';
          )
        end

        dir.down do
          execute %(
            delete permissions
            from permissions
            join roles
            on roles.id = permissions.role_id
            where permissions.value =
              concat('providers:', roles.provider_id, ':attributes:read')
          )
        end
      end

      reversible do |dir|
        dir.up do
          execute %(
            update permissions
            join roles
            on roles.id = permissions.role_id
            set permissions.value =
              concat('providers:', roles.provider_id, ':attributes:*')
            where permissions.value =
              concat('providers:', roles.provider_id, ':attributes:create')
          )
        end

        dir.down do
          execute %(
            update permissions
            join roles
            on roles.id = permissions.role_id
            set permissions.value =
              concat('providers:', roles.provider_id, ':attributes:create')
            where permissions.value =
              concat('providers:', roles.provider_id, ':attributes:*')
          )
        end
      end
    end
  end
end
