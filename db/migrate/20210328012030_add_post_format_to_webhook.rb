class AddPostFormatToWebhook < ActiveRecord::Migration[5.2]
  def change
    add_column :webhooks, :format, :string, default: "json", null: false
  end
end
