class SlackChannelsController < ApplicationController
  before_action :set_workspace
  before_action :set_slack_channel, only: [:show, :edit, :update, :destroy]

  def show
    @events = @channel.slack_events.order(created_at: :desc).limit(50)
    @summary = Summary.where(source: @channel).order(created_at: :desc).first
    @action_items = @summary&.action_items&.order(created_at: :asc) || ActionItem.none
    @workspaces = Workspace.includes(:slack_channels).all
  end

  def new
    @channel = @workspace.slack_channels.build
    existing_ids = @workspace.slack_channels.pluck(:channel_id)
    @available_channels = @workspace.fetch_slack_channels.reject { |_, id| existing_ids.include?(id) }
  end

  def available
    existing_ids = @workspace.slack_channels.pluck(:channel_id)
    @available_channels = @workspace.fetch_slack_channels.reject { |_, id| existing_ids.include?(id) }
    render layout: false
  end

  def create
    @channel = @workspace.slack_channels.build(slack_channel_params)
    if @channel.save
      redirect_to root_path, notice: "Channel added."
    else
      existing_ids = @workspace.slack_channels.pluck(:channel_id)
      @available_channels = @workspace.fetch_slack_channels.reject { |_, id| existing_ids.include?(id) }
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @channel.update(slack_channel_params)
      redirect_to workspace_slack_channel_path(@workspace, @channel), notice: "Channel updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @channel.destroy
    redirect_to root_path, notice: "Channel removed."
  end

  private

  def set_workspace
    @workspace = Workspace.find(params[:workspace_id])
  end

  def set_slack_channel
    @channel = @workspace.slack_channels.find(params[:id])
  end

  def slack_channel_params
    params.require(:slack_channel).permit(:channel_id, :channel_name, :active)
  end
end
