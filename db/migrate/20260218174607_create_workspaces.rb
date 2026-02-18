class CreateWorkspaces < ActiveRecord::Migration[8.0]
  def change
    create_table :workspaces do |t|
      t.text :team_id, null: false
      t.text :team_name
      t.text :user_token
      t.text :signing_secret

      t.timestamps
    end

    add_index :workspaces, :team_id, unique: true
  end
end
