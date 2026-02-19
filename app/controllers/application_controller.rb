class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate

  private

  def authenticate
    return unless http_basic_auth_configured?

    authenticate_or_request_with_http_basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(username, ENV["HTTP_BASIC_AUTH_USERNAME"]) &
        ActiveSupport::SecurityUtils.secure_compare(password, ENV["HTTP_BASIC_AUTH_PASSWORD"])
    end
  end

  def http_basic_auth_configured?
    ENV["HTTP_BASIC_AUTH_USERNAME"].present? && ENV["HTTP_BASIC_AUTH_PASSWORD"].present?
  end
end
