class AddPublicFieldToProviders < ActiveRecord::Migration
  def change
    change_table :providers do |t|
      t.boolean :public, null: false, default: true
    end
  end
end
