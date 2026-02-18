class CreateSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :summaries do |t|
      t.references :workspace, null: false, foreign_key: true
      t.text :channel_id, null: false
      t.datetime :period_start
      t.datetime :period_end
      t.text :summary_text
      t.text :model_used

      t.timestamps
    end
  end
end
