# frozen_string_literal: true
class AddPublicFieldToProvidedAttributes < ActiveRecord::Migration
  def change
    change_table :provided_attributes do |t|
      t.boolean :public, null: false, default: true
    end
  end
end
