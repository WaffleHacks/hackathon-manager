class CreateWebhookHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :webhook_histories do |t|
      t.belongs_to :webhook, foreign_key: true
      t.integer :status_code
      t.string :body

      t.timestamps
    end
  end
end
