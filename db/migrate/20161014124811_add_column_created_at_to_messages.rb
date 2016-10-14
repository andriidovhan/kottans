class AddColumnCreatedAtToMessages < ActiveRecord::Migration[4.2]
  def change
    change_table :messages do |t|
      t.column :created_at, :datetime
    end
  end
end