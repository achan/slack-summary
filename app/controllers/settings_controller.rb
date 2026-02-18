class SettingsController < ApplicationController
  def show
  end

  def refresh_slack_cache
    Workspace.find_each(&:clear_slack_channels_cache)
    redirect_to settings_path, notice: "Slack channels cache refreshed."
  end
end
