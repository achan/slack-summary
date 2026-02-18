require "test_helper"

class ChannelTest < ActiveSupport::TestCase
  test "validates channel_id presence" do
    channel = Channel.new(workspace: workspaces(:one))
    assert_not channel.valid?
    assert_includes channel.errors[:channel_id], "can't be blank"
  end

  test "validates uniqueness scoped to workspace" do
    channel = Channel.new(
      workspace: workspaces(:one),
      channel_id: channels(:general).channel_id,
      channel_name: "dup"
    )
    assert_not channel.valid?
    assert_includes channel.errors[:channel_id], "has already been taken"
  end

  test "active scope returns only active channels" do
    workspace = workspaces(:one)
    active = workspace.channels.active
    assert active.all?(&:active?)
    assert_equal 1, active.count
  end
end
