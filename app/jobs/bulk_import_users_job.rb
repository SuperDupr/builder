# require 'aws-sdk-s3'

class BulkImportUsersJob < ApplicationJob
  queue_as :default

  def perform(file_name, account)
    if Rails.env.production?
      # s3 = Aws::S3::Client.new
      # file_stream_or_path = s3.get_object(bucket: ENV['AWS_BUCKET'], key: account.users_file_upload.key).body
    else
      file_stream_or_path = account.users_uploaded_file_path
    end

    # Open the spreadsheet
    spreadsheet = Account.open_spreadsheet(file_stream_or_path, file_name)

    # Parse the spreadsheet
    Account.parse_spreadsheet(spreadsheet, file_name, account)
  end

  after_perform do |job|
    # Here we'll be sending email to admin for bulk import progress ...
    AccountInvitationsMailer.notify_for_users_upload_progress(job.arguments[1].id).deliver_later
  end
end
