# frozen_string_literal: true
class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.belongs_to :provider, null: true, default: nil
      t.string :name, null: false, default: nil
      t.timestamps

      t.index :provider_id
    end
  end
end
