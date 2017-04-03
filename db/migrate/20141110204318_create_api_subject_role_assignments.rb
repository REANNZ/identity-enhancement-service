# frozen_string_literal: true

class CreateAPISubjectRoleAssignments < ActiveRecord::Migration
  def change
    create_table :api_subject_role_assignments do |t|
      t.belongs_to :api_subject, null: false, default: nil
      t.belongs_to :role, null: false, default: nil
      t.timestamps
    end
  end
end
