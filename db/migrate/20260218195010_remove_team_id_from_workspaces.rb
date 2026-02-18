class RemoveTeamIdFromWorkspaces < ActiveRecord::Migration[8.0]
  def change
    remove_index :workspaces, :team_id
    remove_column :workspaces, :team_id, :text, null: false
  end
end
