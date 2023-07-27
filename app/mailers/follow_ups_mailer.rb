class FollowUpsMailer < ApplicationMailer
  def account_owner_setup(account, temp_password)
    @account = account
    @temp_password = temp_password

    mail(
      to: @account.owner.email,
      from: email_address_with_name(Jumpstart.config.support_email, "Feed The Elephant - Team"),
      subject: "Admin Account setup for Organization: - #{@account.name}"
    )
  end
end
