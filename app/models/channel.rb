class Channel < ApplicationRecord
  belongs_to :workspace

  validates :channel_id, presence: true, uniqueness: { scope: :workspace_id }

  scope :active, -> { where(active: true) }
end
