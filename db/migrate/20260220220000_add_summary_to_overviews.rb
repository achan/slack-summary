class AddSummaryToOverviews < ActiveRecord::Migration[8.0]
  def change
    add_column :overviews, :summary, :text
  end
end
