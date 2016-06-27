# frozen_string_literal: true
class CreateSubjectRoleAssignments < ActiveRecord::Migration
  def change
    create_table :subject_role_assignments do |t|
      t.belongs_to :subject, null: false, default: nil
      t.belongs_to :role, null: false, default: nil
      t.timestamps
    end
  end
end
