class AccountInvitationsMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.account_invitations_mailer.invite.subject
  #
  def invite
    @account_invitation = params[:account_invitation]
    @account = @account_invitation.account
    @invited_by = @account_invitation.invited_by

    mail(
      to: email_address_with_name(@account_invitation.email, @account_invitation.full_name),
      from: email_address_with_name(Jumpstart.config.support_email, @invited_by.name),
      subject: t(".subject", inviter: @invited_by.name, account: @account.name)
    )
  end

  def notify_for_users_upload_progress(account_id)
    @account = Account.find(account_id)

    mail(
      to: "admin@test.com", # email_address_with_name(@account.owner.email, @account.owner.full_name)
      from: email_address_with_name(Jumpstart.config.support_email, "Feed The Elephant - Team"),
      subject: "Update on your Bulk Import Users request"
    )
  end
end
