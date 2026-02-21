class UpdateActionItemStatuses < ActiveRecord::Migration[8.0]
  def up
    ActionItem.where(status: "open").update_all(status: "untriaged")
    ActionItem.where(status: "dismissed").update_all(status: "wont_fix")
    ActionItem.where(status: "ready").update_all(status: "todo")

    change_column_default :action_items, :status, "untriaged"
  end

  def down
    ActionItem.where(status: "todo").update_all(status: "ready")
    ActionItem.where(status: "untriaged").update_all(status: "open")
    ActionItem.where(status: "wont_fix").update_all(status: "dismissed")

    change_column_default :action_items, :status, "open"
  end
end
