# frozen_string_literal: true

class SubjectGumbootCompliance < ActiveRecord::Migration
  def change
    change_table :subjects do |t|
      t.boolean :enabled, null: false, default: true
    end
  end
end
