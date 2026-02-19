class CreateLiveActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :live_activities do |t|
      t.text :activity_id, null: false
      t.text :activity_type, null: false
      t.text :title, null: false
      t.text :subtitle
      t.text :status, default: "active", null: false
      t.json :metadata, default: {}
      t.datetime :ends_at
      t.timestamps
    end

    add_index :live_activities, [:activity_type, :activity_id], unique: true
  end
end
