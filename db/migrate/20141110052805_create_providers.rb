# frozen_string_literal: true
class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name, null: false, default: nil
      t.string :description, null: false, default: ''
      t.string :identifier, null: false, default: nil
      t.timestamps
    end
  end
end
