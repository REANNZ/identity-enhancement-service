# frozen_string_literal: true
class APISubjectRevertContactMail < ActiveRecord::Migration
  def change
    rename_column :api_subjects, :mail, :contact_mail
  end
end
