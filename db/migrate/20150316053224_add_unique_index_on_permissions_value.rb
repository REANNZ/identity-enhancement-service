# frozen_string_literal: true

class AddUniqueIndexOnPermissionsValue < ActiveRecord::Migration
  def change
    remove_index :permissions, :role_id
    add_index :permissions, %i(role_id value), unique: true
  end
end
