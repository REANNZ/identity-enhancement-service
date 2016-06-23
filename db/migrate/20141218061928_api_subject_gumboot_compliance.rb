# frozen_string_literal: true
class APISubjectGumbootCompliance < ActiveRecord::Migration
  def change
    change_table :api_subjects do |t|
      t.rename :contact_mail, :mail
      t.boolean :enabled, null: false, default: true
    end
  end
end
