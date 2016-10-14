class CreateMessages < ActiveRecord::Migration[4.2]
  def change
    create_table :messages do |t|
      t.string :message
    end
    Messages.create(message: "first message via rubymine")
  end
end

class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :admin, :boolean, :default => false
  end
end