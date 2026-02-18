class Summary < ApplicationRecord
  belongs_to :workspace
  has_many :action_items, dependent: :destroy

  validates :channel_id, presence: true

  after_create_commit :broadcast_summary

  private

  def broadcast_summary
    broadcast_replace_to(
      "workspace_#{workspace_id}_channel_#{channel_id}_summary",
      target: "latest_summary",
      partial: "summaries/summary",
      locals: { summary: self }
    )
  end
end
