# frozen_string_literal: true
class AddUniqueIndexToInvitationsSubjectId < ActiveRecord::Migration
  def change
    add_index :invitations, :subject_id, unique: true
  end
end
