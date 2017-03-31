# frozen_string_literal: true

class AddLastSentAtToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :last_sent_at, :timestamp, null: false

    reversible do |dir|
      dir.up { execute 'update invitations set last_sent_at = created_at' }
    end
  end
end
