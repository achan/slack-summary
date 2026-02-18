class Event < ApplicationRecord
  belongs_to :workspace

  validates :event_id, presence: true, uniqueness: true
  validates :channel_id, presence: true

  scope :for_channel, ->(channel_id) { where(channel_id: channel_id) }
  scope :in_window, ->(start_time, end_time) { where(created_at: start_time..end_time) }
  scope :messages, -> { where(event_type: "message") }

  after_create_commit :broadcast_event

  private

  def broadcast_event
    broadcast_prepend_to(
      "workspace_#{workspace_id}_channel_#{channel_id}_events",
      target: "events",
      partial: "events/event",
      locals: { event: self }
    )
  end
end
