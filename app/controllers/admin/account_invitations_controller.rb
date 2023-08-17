module Admin
  class AccountInvitationsController < Admin::ApplicationController
    before_action :set_account
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #

    def new
      @account_invitation = @account.account_invitations.new
      @teams = @account.teams
    end

    def create
      @account_invitation = @account.account_invitations.new(account_invitation_params)
      @account_invitation.roles[params[:roles]] = true
      @account_invitation.invited_by_id = current_user.id
      @account_invitation.team_name = get_team_name if params[:account_invitation][:team_id].present?

      if @account.owner.present?
        if @account_invitation.save_and_send_invite
          redirect_to(invited_users_admin_account_path(@account.id), notice: "User invitation created successfully!")
        else
          redirect_to(invited_users_admin_account_path(@account.id),
            alert: "Unable to create user invitation. Errors: #{@account_invitation.errors.full_messages.join(", ")}")
        end
      else
        begin
          @account_invitation.save
          user, temp_password = @account_invitation.create_user_reflection
          @account_invitation.accept!(user, true)
          @account.update(owner_id: user.id)
          FollowUpsMailer.account_owner_setup(@account, temp_password).deliver_later
          redirect_to(invited_users_admin_account_path(@account.id), notice: "Organization owner has been added successfully!")
        rescue => e
          redirect_to(invited_users_admin_account_path(@account.id), alert: "Unable to create user invitation. Error: #{e.message}")
        end
      end
    end

    def bulk_import
      @account.users_file_upload.attach(params[:file])
      file_name = @account.users_uploaded_file_name

      begin
        AccountInvitation.import_file(file_name, @account)
        redirect_to(invited_users_admin_account_path(@account.id), notice: "Import process has been started. We'll email you about the progress sooner!")
      rescue => e
        redirect_to(invited_users_admin_account_path(@account.id), alert: "Unable to process your request. Errors: #{e.message}")
      end
    end

    # def update
    #   foo = Foo.find(params[:id])
    #   foo.update(params[:foo])
    #   send_foo_updated_email
    # end

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

    private

    def set_account
      @account = Account.find(params[:id])
    end

    def get_team_name
      Team.find_by(id: params[:account_invitation][:team_id])&.name
    end

    def account_invitation_params
      params.require(:account_invitation).permit(:email, :first_name, :last_name, :team_id)
    end
  end
end
