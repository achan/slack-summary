require "test_helper"

class SummarizeJobTest < ActiveSupport::TestCase
  test "groups events by thread" do
    workspace = workspaces(:one)
    job = SummarizeJob.new

    # Create a threaded event
    Event.create!(
      workspace: workspace,
      event_id: "Ev_THREAD_001",
      channel_id: "C_GENERAL",
      event_type: "message",
      user_id: "U_USER2",
      ts: "1700000002.000001",
      thread_ts: "1700000001.000001",
      payload: { "text" => "Reply in thread", "type" => "message" }
    )

    events = workspace.events.for_channel("C_GENERAL").in_window(2.days.ago, Time.current).order(:created_at)
    grouped = job.send(:group_by_thread, events)

    assert grouped[:top_level].any? { |e| e.ts == "1700000001.000001" }
    assert grouped[:threads]["1700000001.000001"]&.any? { |e| e.ts == "1700000002.000001" }
  end

  test "skips when no events in window" do
    workspace = workspaces(:two)

    assert_no_difference "Summary.count" do
      SummarizeJob.perform_now(
        workspace_id: workspace.id,
        channel_id: "C_NONEXISTENT",
        period_start: 1.hour.ago,
        period_end: Time.current
      )
    end
  end
end
