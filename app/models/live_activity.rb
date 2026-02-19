class LiveActivity < ApplicationRecord
  scope :visible, -> { where(status: "active").or(where(status: "ending").where("ends_at > ?", Time.current)) }

  after_create_commit :broadcast_prepend
  after_update_commit :broadcast_replace

  private

  def broadcast_prepend
    broadcast_prepend_to(
      "dashboard_live_activities",
      target: "dashboard_live_activities",
      partial: "dashboard/live_activity",
      locals: { live_activity: self }
    )
  end

  def broadcast_replace
    broadcast_replace_to(
      "dashboard_live_activities",
      target: "live_activity_#{id}",
      partial: "dashboard/live_activity",
      locals: { live_activity: self }
    )
  end
end
