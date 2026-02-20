class AddPredecessorIdToSlackChannels < ActiveRecord::Migration[8.0]
  def change
    add_column :slack_channels, :predecessor_id, :integer
    add_index :slack_channels, :predecessor_id
    add_foreign_key :slack_channels, :slack_channels, column: :predecessor_id

    reversible do |dir|
      dir.up do
        # Group channels by (workspace_id, channel_name), ordered by created_at.
        # Within each group, link each channel to its immediate predecessor.
        # Skip DMs (D*), MPIMs (G*), and channels with unresolved names.
        execute <<~SQL
          UPDATE slack_channels
          SET predecessor_id = (
            SELECT prev.id
            FROM slack_channels prev
            WHERE prev.workspace_id = slack_channels.workspace_id
              AND prev.channel_name = slack_channels.channel_name
              AND prev.created_at < slack_channels.created_at
              AND prev.channel_name IS NOT NULL
              AND prev.channel_name != prev.channel_id
              AND prev.channel_id NOT LIKE 'D%'
              AND prev.channel_id NOT LIKE 'G%'
            ORDER BY prev.created_at DESC
            LIMIT 1
          )
          WHERE channel_name IS NOT NULL
            AND channel_name != channel_id
            AND channel_id NOT LIKE 'D%'
            AND channel_id NOT LIKE 'G%'
            AND EXISTS (
              SELECT 1 FROM slack_channels prev
              WHERE prev.workspace_id = slack_channels.workspace_id
                AND prev.channel_name = slack_channels.channel_name
                AND prev.created_at < slack_channels.created_at
                AND prev.channel_id NOT LIKE 'D%'
                AND prev.channel_id NOT LIKE 'G%'
            )
        SQL
      end
    end
  end
end
