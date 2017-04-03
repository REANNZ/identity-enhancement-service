# frozen_string_literal: true

class CreateAPISubjects < ActiveRecord::Migration
  def change
    create_table :api_subjects do |t|
      t.belongs_to :provider, null: false, default: nil
      t.string :x509_cn, null: false, default: nil
      t.string :name, null: false, default: nil
      t.string :description, null: false, default: '', length: 4096
      t.string :contact_name, null: false, default: nil
      t.string :contact_mail, null: false, default: nil
      t.timestamps
    end
  end
end
