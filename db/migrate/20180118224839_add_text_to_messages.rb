class AddTextToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :sender_message, :string
    add_column :messages, :recipient_message, :string
  end
end
