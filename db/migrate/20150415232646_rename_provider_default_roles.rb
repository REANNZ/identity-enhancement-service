class RenameProviderDefaultRoles < ActiveRecord::Migration
  class Role < ActiveRecord::Base
  end

  def change
    changes = {
      api_ro: 'API Read Only',
      api_rw: 'API Read/Write',
      web_ro: 'Web UI Read Only',
      web_rw: 'Web UI Read/Write',
      admin: 'Administrator'
    }

    Role.transaction do
      changes.each do |from, to|
        reversible do |dir|
          dir.up { Role.where(name: from).update_all(name: to) }
          dir.down { Role.where(name: to).update_all(name: from) }
        end
      end
    end
  end
end
