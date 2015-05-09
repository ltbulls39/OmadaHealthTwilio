class RenameSenderAndRecipientColumns < ActiveRecord::Migration
  def change
    rename_column :messages, :sender, :sender_email
    rename_column :messages, :recipient, :recipient_email
    add_column :messages, :sender_phone, :string
    add_column :messages, :recipient_phone, :string
  end
end
