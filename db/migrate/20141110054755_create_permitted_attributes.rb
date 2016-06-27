# frozen_string_literal: true
class CreatePermittedAttributes < ActiveRecord::Migration
  def change
    create_table :permitted_attributes do |t|
      t.belongs_to :provider, null: false, default: nil
      t.belongs_to :available_attribute, null: false, default: nil
      t.timestamps

      t.index :provider_id
    end
  end
end
