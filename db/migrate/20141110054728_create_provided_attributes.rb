# frozen_string_literal: true

class CreateProvidedAttributes < ActiveRecord::Migration
  def change
    create_table :provided_attributes do |t|
      t.belongs_to :permitted_attribute, null: false, default: nil
      t.belongs_to :subject, null: false, default: nil
      t.string :name, null: false, default: nil
      t.string :value, null: false, default: nil
      t.timestamps

      t.index :subject_id
    end
  end
end
