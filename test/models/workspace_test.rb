require "test_helper"

class WorkspaceTest < ActiveSupport::TestCase
  test "validates team_name presence" do
    workspace = Workspace.new
    assert_not workspace.valid?
    assert_includes workspace.errors[:team_name], "can't be blank"
  end

  test "encrypts user_token" do
    assert_includes Workspace.encrypted_attributes, :user_token
  end
end
