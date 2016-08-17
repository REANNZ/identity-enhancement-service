# frozen_string_literal: true
class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.belongs_to :role, null: false, default: nil
      t.string :value, null: false, default: nil
      t.timestamps

      t.index :role_id
    end
  end
end
