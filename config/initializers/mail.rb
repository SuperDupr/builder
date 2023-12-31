# Assign the from email address in all environments
Rails.application.reloader.to_prepare do
  ActionMailer::Base.default_options = {from: Jumpstart.config.default_from_email}

  if Rails.env.production? # || Rails.env.staging?
    ActionMailer::Base.default_url_options[:host] = "app.feedtheelephant.com"
    ActionMailer::Base.default_url_options[:protocol] = "https"
    ActionMailer::Base.smtp_settings.merge!(Jumpstart::Mailer.new(Jumpstart.config).settings)
  elsif Rails.env.staging?
    ActionMailer::Base.default_url_options[:host] = "staging.feedtheelephant.com"
    ActionMailer::Base.default_url_options[:protocol] = "https"
    ActionMailer::Base.smtp_settings.merge!(Jumpstart::Mailer.new(Jumpstart.config).settings)
  end
end
