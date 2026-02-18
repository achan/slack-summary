class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :workspace, null: false, foreign_key: true
      t.text :event_id, null: false
      t.text :channel_id, null: false
      t.text :event_type
      t.text :user_id
      t.text :ts
      t.text :thread_ts
      t.json :payload

      t.timestamps
    end

    add_index :events, :event_id, unique: true
    add_index :events, [ :workspace_id, :channel_id, :created_at ]
  end
end
