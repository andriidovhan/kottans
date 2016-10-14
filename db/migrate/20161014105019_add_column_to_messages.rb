class AddColumnToMessages < ActiveRecord::Migration
  def change
    change_table :messages do |t|
      t.column :destruction, :integer, default: false
    end
  end
end