class Workspace < ApplicationRecord
  encrypts :user_token

  has_many :channels, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :summaries, dependent: :destroy
  has_many :action_items, dependent: :destroy

  validates :team_id, presence: true, uniqueness: true

  def active_channel_ids
    channels.active.pluck(:channel_id)
  end
end
