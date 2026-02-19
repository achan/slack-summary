class LiveActivityCleanupJob < ApplicationJob
  def perform(live_activity_id)
    activity = LiveActivity.find_by(id: live_activity_id)
    return unless activity
    return unless activity.ends_at && activity.ends_at <= Time.current

    activity.broadcast_remove_to("dashboard_live_activities", target: "live_activity_#{activity.id}")
    activity.destroy
  end
end
