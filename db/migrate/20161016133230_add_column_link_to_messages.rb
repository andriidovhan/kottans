class AddColumnLinkToMessages < ActiveRecord::Migration
  def change
    change_table :messages do |t|
      t.column :link, :string
    end
  end
end
