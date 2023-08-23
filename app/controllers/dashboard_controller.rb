class DashboardController < ApplicationController
  def show
    @pagy, @account_users = pagy(current_account.account_users.includes(:user))
  end
end
