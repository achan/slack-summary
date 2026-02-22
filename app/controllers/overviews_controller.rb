class OverviewsController < ApplicationController
  def create
    GenerateOverviewJob.perform_later
    head :no_content
  end
end
