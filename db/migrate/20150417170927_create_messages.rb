class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :secure_id
      t.string :sender
      t.string :recipient
      t.text :body

      t.timestamps null: false
    end
  end
end
