class ChannelsController < ApplicationController
  def show
    @workspace = Workspace.find(params[:workspace_id])
    @channel = @workspace.channels.find_by!(channel_id: params[:id])
    @events = @workspace.events.for_channel(@channel.channel_id).order(created_at: :desc).limit(50)
    @summary = @workspace.summaries.where(channel_id: @channel.channel_id).order(created_at: :desc).first
    @action_items = @summary&.action_items&.order(created_at: :asc) || ActionItem.none
    @workspaces = Workspace.includes(:channels).all
  end
end
