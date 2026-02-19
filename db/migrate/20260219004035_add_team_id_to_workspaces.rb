class AddTeamIdToWorkspaces < ActiveRecord::Migration[8.0]
  def change
    add_column :workspaces, :team_id, :text
  end
end
