require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "validates event_id presence" do
    event = Event.new(workspace: workspaces(:one), channel_id: "C_TEST")
    assert_not event.valid?
    assert_includes event.errors[:event_id], "can't be blank"
  end

  test "validates event_id uniqueness" do
    event = Event.new(
      workspace: workspaces(:one),
      event_id: events(:message_one).event_id,
      channel_id: "C_TEST"
    )
    assert_not event.valid?
    assert_includes event.errors[:event_id], "has already been taken"
  end

  test "for_channel scope filters by channel_id" do
    events = Event.for_channel("C_GENERAL")
    assert events.all? { |e| e.channel_id == "C_GENERAL" }
  end

  test "in_window scope filters by created_at range" do
    events = Event.in_window(2.days.ago, Time.current)
    assert events.all? { |e| e.created_at >= 2.days.ago }
  end
end
