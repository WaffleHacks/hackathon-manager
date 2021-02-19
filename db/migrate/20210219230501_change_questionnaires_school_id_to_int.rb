class ChangeQuestionnairesSchoolIdToInt < ActiveRecord::Migration[5.2]
  def change
    execute "ALTER TABLE questionnaires ALTER COLUMN school_id SET DATA TYPE int USING school_id::int"
  end
end
