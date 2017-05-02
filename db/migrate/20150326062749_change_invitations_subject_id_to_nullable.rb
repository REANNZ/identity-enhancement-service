# frozen_string_literal: true

class ChangeInvitationsSubjectIdToNullable < ActiveRecord::Migration
  def change
    change_column_null :invitations, :subject_id, true
  end
end
