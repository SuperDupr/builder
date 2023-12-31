# In our app this controller serves the purpose of organizations controller
# Being wrapped in the admin scope, an Organization of FTE is equivalent of
# Account in Jumpstart

module Admin
  class AccountsController < Admin::ApplicationController
    # Overwrite any of the RESTful controller actions to implement custom behavior

    # Callbacks
    before_action :set_account, only: [:organization_users, :invited_users, :manage_access]

    def create
      super
      flash[:notice] = "Organization was created successfully!"
    end

    def update
      super
      flash[:notice] = "Organization was updated successfully!"
    end

    def destroy
      super
      flash[:notice] = "Organization was deleted successfully!"
    end

    def organization_users
      @pagy, @account_users = pagy(@account.account_users.includes(:user))
    end

    def invited_users
      @pagy, @account_invitations = pagy(@account.account_invitations)
    end

    def manage_access
      @account.toggle!(:active)

      render json: {access: @account.active}
    end

    private

    def set_account
      @account = Account.find(params[:id])
    end

    def organization_status(active)
      active ? "activated" : "inactivated"
    end

    # Override this method to specify custom lookup behavior.
    # This will be used to set the resource for the `show`, `edit`, and `update`
    # actions.
    #
    # def find_resource(param)
    #   Foo.find_by!(slug: param)
    # end

    # Override this if you have certain roles that require a subset
    # this will be used to set the records shown on the `index` action.
    #
    # def scoped_resource
    #  if current_user.super_admin?
    #    resource_class
    #  else
    #    resource_class.with_less_stuff
    #  end
    # end

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
