class AddUniqueIndexOnPermissionsValue < ActiveRecord::Migration
  def change
    remove_index :permissions, :role_id
    add_index :permissions, [:role_id, :value], unique: true
  end
end
