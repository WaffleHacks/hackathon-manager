class MoveUserInfoFromQuestionnaireToUserModel < ActiveRecord::Migration[5.2]
  # See the "Hackathon Manager 2.0 Migration Guide"
  # for a more general description of what this migration does.

  # Effectively, we move the `first_name` and `last_name` columns
  # from the questionnares table to the users table (and model, for both).

  def up
    # Add the first/last name columns to the users table
    add_column :users, :first_name, :string
    add_column :users, :last_name,  :string

    # Copy the data
    execute "UPDATE users SET first_name = questionnaires.first_name FROM questionnaires WHERE users.id = questionnaires.user_id"
    execute "UPDATE users SET last_name  = questionnaires.last_name  FROM questionnaires WHERE users.id = questionnaires.user_id"

    # If either first or last name is null,
    # use the first part of their email as their first and last name.
    # It is not currently possible to set only one and not the other,
    # but we are "handling" that case nevertheless.
    #
    # This is needed because first and last names are REQUIRED to be non-nil.
    User.where("first_name IS NULL AND last_name IS NULL").each do |u|
      email_head   = u.email.partition('@').first
      u.first_name = email_head
      u.last_name  = email_head
      u.save
    end

    # Remove the first/last name columns from the questionnaires table
    remove_column :questionnaires, :first_name, :string
    remove_column :questionnaires, :last_name,  :string
  end

  def down
    # Add the first/last name columns back to the questionnaires table
    add_column :questionnaires, :first_name, :string
    add_column :questionnaires, :last_name,  :string

    # Copy the data
    execute "UPDATE questionnaires SET first_name = users.first_name FROM users WHERE questionnaires.user_id = users.id"
    execute "UPDATE questionnaires SET last_name  = users.last_name  FROM users WHERE questionnaires.user_id = users.id"

    # For all users, undo the email assignment scheme we did before,
    # and set both their first/last name to nil.
    User.all.each do |u|
      email_head = u.email.partition('@').first
      if u.first_name == email_head && u.last_name == email_head
        u.first_name = nil
        u.last_name  = nil
      end
    end

    # Finally, remove the first/last name columns from the users table.
    remove_column :users, :first_name, :string
    remove_column :users, :last_name,  :string
  end
end
