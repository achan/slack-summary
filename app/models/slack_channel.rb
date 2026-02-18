class SlackChannel < ApplicationRecord
  belongs_to :workspace

  has_many :slack_events, dependent: :destroy
  has_many :summaries, as: :source, dependent: :destroy
  has_many :action_items, as: :source, dependent: :destroy

  validates :channel_id, presence: true, uniqueness: { scope: :workspace_id }

  before_save :populate_channel_name, if: -> { channel_name.blank? && workspace&.user_token.present? }

  scope :active, -> { where(active: true) }

  private

  def populate_channel_name
    client = Slack::Web::Client.new(token: workspace.user_token)
    info = client.conversations_info(channel: channel_id)

    self.channel_name = info.channel.name
  rescue Slack::Web::Api::Errors::SlackError
    # Leave channel_name blank if the API call fails
  end
end
