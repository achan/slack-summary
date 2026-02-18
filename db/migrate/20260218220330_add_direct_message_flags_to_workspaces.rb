class AddDirectMessageFlagsToWorkspaces < ActiveRecord::Migration[8.0]
  def change
    add_column :workspaces, :include_dms, :boolean, default: false, null: false
    add_column :workspaces, :include_mpims, :boolean, default: false, null: false
  end
end
