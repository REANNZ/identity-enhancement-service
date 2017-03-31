# frozen_string_literal: true

class RemoveAPISubjectsName < ActiveRecord::Migration
  def change
    remove_column :api_subjects, :name
  end
end
