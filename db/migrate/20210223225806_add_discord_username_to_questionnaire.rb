class AddDiscordUsernameToQuestionnaire < ActiveRecord::Migration[5.2]
  def change
    add_column :questionnaires, :discord, :string
  end
end
