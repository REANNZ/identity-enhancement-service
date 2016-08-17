# frozen_string_literal: true
class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :name, null: false, default: nil
      t.string :mail, null: false, default: nil
      t.string :targeted_id, null: true, default: nil
      t.string :shared_token, null: true, default: nil
      t.boolean :complete, null: false, default: false
      t.timestamps

      t.index :targeted_id
      t.index :shared_token, unique: true
    end
  end
end
