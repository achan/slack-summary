require "test_helper"

class ActionItemTest < ActiveSupport::TestCase
  test "validates description presence" do
    item = ActionItem.new(
      summary: summaries(:recent_summary),
      workspace: workspaces(:one),
      channel_id: "C_GENERAL",
      status: "open"
    )
    assert_not item.valid?
    assert_includes item.errors[:description], "can't be blank"
  end

  test "validates status inclusion" do
    item = ActionItem.new(
      summary: summaries(:recent_summary),
      workspace: workspaces(:one),
      channel_id: "C_GENERAL",
      description: "Test",
      status: "invalid"
    )
    assert_not item.valid?
    assert_includes item.errors[:status], "is not included in the list"
  end

  test "open_items scope returns only open items" do
    items = ActionItem.open_items
    assert items.all? { |i| i.status == "open" }
  end
end
