class AllowMultipleEventsPerWebhook < ActiveRecord::Migration[5.2]
  def up
    remove_column :webhooks, :event
    add_column :webhooks, :events, :integer, null: false, default: 0
  end

  def down
    remove_column :webhooks, :events
    add_column :webhooks, :event, :string, null: false, default: ""
  end
end
