# frozen_string_literal: true
class CreateRequestedEnhancements < ActiveRecord::Migration
  def change
    create_table :requested_enhancements do |t|
      t.belongs_to :subject, null: false
      t.belongs_to :provider, null: false

      t.string :message, limit: 4096, null: false, default: nil
      t.timestamps null: false

      t.boolean :actioned, null: false, default: false
      t.belongs_to :actioned_by, null: true, default: nil
    end
  end
end
