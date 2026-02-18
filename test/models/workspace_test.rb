require "test_helper"

class WorkspaceTest < ActiveSupport::TestCase
  test "validates team_id presence" do
    workspace = Workspace.new(team_name: "Test")
    assert_not workspace.valid?
    assert_includes workspace.errors[:team_id], "can't be blank"
  end

  test "validates team_id uniqueness" do
    workspace = Workspace.new(team_id: workspaces(:one).team_id, team_name: "Dup")
    assert_not workspace.valid?
    assert_includes workspace.errors[:team_id], "has already been taken"
  end

  test "active_channel_ids returns only active channels" do
    workspace = workspaces(:one)
    ids = workspace.active_channel_ids
    assert_includes ids, "C_GENERAL"
    assert_not_includes ids, "C_RANDOM"
  end

  test "encrypts user_token" do
    assert_includes Workspace.encrypted_attributes, :user_token
  end
end
