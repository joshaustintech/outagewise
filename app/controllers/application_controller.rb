class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_demo_context

  helper_method :current_account, :current_user

  private

  def set_demo_context
    Current.account = Account.includes(:users, :customer_database).order(:id).first
    Current.user = Current.account&.users&.first
  end

  def current_account
    Current.account
  end

  def current_user
    Current.user
  end
end
