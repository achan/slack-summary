class DashboardController < ApplicationController
  def show
    @workspaces = Workspace.includes(:channels).all
  end
end
