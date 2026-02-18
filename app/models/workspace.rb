class Workspace < ApplicationRecord
  encrypts :user_token

  has_many :slack_channels, dependent: :destroy

  validates :team_name, presence: true

  def fetch_slack_channels
    return [] if user_token.blank?

    Rails.cache.fetch("workspace_#{id}_slack_channels", expires_in: 5.minutes) do
      client = Slack::Web::Client.new(token: user_token)
      list_conversations(client, "public_channel,private_channel").sort_by(&:first)
    end
  rescue ActiveRecord::Encryption::Errors::Decryption
    []
  end

  def slack_client
    Slack::Web::Client.new(token: user_token)
  end

  private

  def list_conversations(client, types)
    channels = []
    cursor = nil

    loop do
      response = client.conversations_list(
        types: types,
        exclude_archived: true,
        limit: 200,
        cursor: cursor
      )
      channels.concat(response.channels.map { |c| [c.name || c.id, c.id] })
      cursor = response.response_metadata&.next_cursor
      break if cursor.blank?
    end

    channels
  rescue Slack::Web::Api::Errors::SlackError, Faraday::Error
    []
  end
end
