class CreateWebhooks < ActiveRecord::Migration[5.2]
  def change
    create_table :webhooks do |t|
      t.string :event, null: false
      t.string :url, null: false
      t.string :secret
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
