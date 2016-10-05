class CreateMessages < ActiveRecord::Migration[4.2]
  def change
    create_table :messages do |t|
      t.string :message
    end
    Messages.create(message: "first message via rubymine")
  end
end
