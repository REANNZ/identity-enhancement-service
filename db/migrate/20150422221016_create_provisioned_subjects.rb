# frozen_string_literal: true

class CreateProvisionedSubjects < ActiveRecord::Migration
  def change
    create_table :provisioned_subjects do |t|
      t.belongs_to :subject, null: false
      t.belongs_to :provider, null: false

      t.timestamp :expires_at, null: true

      t.timestamps null: false

      t.index %i(subject_id provider_id), unique: true
    end
  end
end
