class Workspace < ApplicationRecord
  encrypts :user_token

  has_many :slack_channels, dependent: :destroy

  validates :team_name, presence: true

  def fetch_slack_channels
    return [] if user_token.blank?

    client = Slack::Web::Client.new(token: user_token)
    channels = []
    cursor = nil

    loop do
      response = client.conversations_list(
        types: "public_channel,private_channel,mpim",
        exclude_archived: true,
        limit: 200,
        cursor: cursor
      )
      channels.concat(response.channels.map { |c| [c.name || c.purpose&.value || c.id, c.id] })
      cursor = response.response_metadata&.next_cursor
      break if cursor.blank?
    end

    channels.sort_by(&:first)
  rescue Slack::Web::Api::Errors::SlackError, ActiveRecord::Encryption::Errors::Decryption
    []
  end
end
