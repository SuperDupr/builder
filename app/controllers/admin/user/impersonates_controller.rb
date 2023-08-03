module Admin
  class User::ImpersonatesController < Admin::ApplicationController
    before_action :set_account, only: [:destroy]
    
    def create
      user = ::User.find(params[:user_id])
      impersonate_user(user)
      redirect_to root_path
    end

    def destroy
      user = current_user
      stop_impersonating_user
      redirect_to(organization_users_admin_account_path(@account))
    end
    
    private
    
    def set_account
      @account = Account.find(params[:account_id])
    end
  end
end
