# frozen_string_literal: true
class AddMoreUniqueIndexes < ActiveRecord::Migration
  def change
    add_index :api_subjects, :x509_cn, unique: true
    add_index :api_subject_role_assignments, [:api_subject_id, :role_id],
              unique: true
    add_index :available_attributes, [:name, :value], unique: true
    add_index :permitted_attributes, [:provider_id, :available_attribute_id],
              unique: true, name: 'permitted_attributes_unique_attribute'
    add_index :provided_attributes, [:subject_id, :permitted_attribute_id],
              unique: true, name: 'provided_attributes_unique_attribute'
    add_index :providers, :identifier, unique: true
    add_index :subject_role_assignments, [:subject_id, :role_id], unique: true
    add_index :subjects, :mail, unique: true

    # These indexes are redundant, covered by new composite indexes above.
    remove_index :permitted_attributes,
                 name: 'index_permitted_attributes_on_provider_id'
    remove_index :provided_attributes,
                 name: 'index_provided_attributes_on_subject_id'
  end
end
