# frozen_string_literal: true
class CreateAvailableAttributes < ActiveRecord::Migration
  def change
    create_table :available_attributes do |t|
      t.string :name, null: false, default: nil
      t.string :value, null: false, default: nil
      t.string :description, null: false, default: nil
      t.timestamps
    end
  end
end
