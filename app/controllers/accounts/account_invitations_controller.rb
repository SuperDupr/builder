class Accounts::AccountInvitationsController < Accounts::BaseController
  before_action :set_account
  before_action :require_account_admin
  before_action :set_account_invitation, only: [:edit, :update, :destroy, :resend]

  def new
    @account_invitation = AccountInvitation.new
    @teams = @account.teams
  end

  def create
    @account_invitation = @account.account_invitations.new(invitation_params)
    @account_invitation.roles[params[:roles]] = true
    @account_invitation.invited_by_id = current_user.id
    @account_invitation.team_name = get_team_name if params[:account_invitation][:team_id].present?

    if @account_invitation.save_and_send_invite
      redirect_to(invited_users_account_path(@account), notice: t(".sent", email: @account_invitation.email))
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @account_invitation.update(invitation_params)
      redirect_to @account, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @account_invitation.destroy
    redirect_to @account, status: :see_other, notice: t(".destroyed")
  end

  def resend
    @account_invitation.send_invite
    redirect_to @account, status: :see_other, notice: t(".sent", email: @account_invitation.email)
  end

  def bulk_import
    @account.users_file_upload.attach(params[:file])
    file_name = @account.users_uploaded_file_name

    begin
      AccountInvitation.import_file(file_name, @account)
      redirect_to(invited_users_account_path(@account), notice: "Import process has been started. We'll email you about the progress sooner!")
    rescue => e
      redirect_to(invited_users_account_path(@account.id), alert: "Unable to process your request. Errors: #{e.message}")
    end
  end

  private

  def set_account
    @account = current_user.accounts.find(params[:account_id])
  end

  def set_account_invitation
    @account_invitation = @account.account_invitations.find_by!(token: params[:id])
  end

  def get_team_name
    Team.find_by(id: params[:account_invitation][:team_id])&.name
  end

  def invitation_params
    params
      .require(:account_invitation)
      .permit(:email, :first_name, :last_name, :team_name, :team_id, roles: {})
      .merge(account: @account, invited_by: current_user)
  end
end
