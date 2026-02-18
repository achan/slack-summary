class CreateActionItems < ActiveRecord::Migration[8.0]
  def change
    create_table :action_items do |t|
      t.references :summary, null: false, foreign_key: true
      t.references :workspace, null: false, foreign_key: true
      t.text :channel_id, null: false
      t.text :description, null: false
      t.text :assignee_user_id
      t.text :source_ts
      t.text :status, default: "open", null: false

      t.timestamps
    end

    add_index :action_items, :status
  end
end
