class Workspace < ApplicationRecord
  encrypts :user_token

  has_many :slack_channels, dependent: :destroy

  validates :team_name, presence: true

  before_save :populate_team_id, if: -> { user_token_changed? && user_token.present? }

  def resolve_user_name(user_id)
    return user_id if user_id.blank? || user_token.blank?

    Rails.cache.fetch("slack_user_name/#{id}/#{user_id}", expires_in: 1.hour) do
      info = slack_client.users_info(user: user_id)
      info.user.real_name.presence || info.user.name.presence || user_id
    end
  rescue Slack::Web::Api::Errors::SlackError, Faraday::Error
    user_id
  end

  def fetch_slack_channels
    return [] if user_token.blank?

    Rails.cache.fetch("workspace_#{id}_slack_channels") do
      client = Slack::Web::Client.new(token: user_token)
      list_conversations(client, "public_channel,private_channel").sort_by(&:first)
    end
  rescue ActiveRecord::Encryption::Errors::Decryption
    []
  end

  def clear_slack_channels_cache
    Rails.cache.delete("workspace_#{id}_slack_channels")
  end

  def slack_client
    Slack::Web::Client.new(token: user_token)
  end

  private

  def populate_team_id
    response = slack_client.auth_test
    self.team_id = response.team_id
  rescue Slack::Web::Api::Errors::SlackError, Faraday::Error
    # Leave team_id blank if the API call fails
  end

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
