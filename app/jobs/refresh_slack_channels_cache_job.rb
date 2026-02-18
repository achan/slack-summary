class RefreshSlackChannelsCacheJob < ApplicationJob
  queue_as :default

  def perform
    Workspace.find_each do |workspace|
      workspace.clear_slack_channels_cache
      workspace.fetch_slack_channels
    end

    Rails.logger.info("[RefreshSlackChannelsCacheJob] Refreshed Slack channels cache for all workspaces")
  end
end
