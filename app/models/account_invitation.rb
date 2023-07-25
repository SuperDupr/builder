# == Schema Information
#
# Table name: account_invitations
#
#  id            :bigint           not null, primary key
#  email         :string           not null
#  first_name    :string
#  imported      :boolean          default(FALSE)
#  last_name     :string
#  name          :string
#  roles         :jsonb            not null
#  team_name     :string
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  account_id    :bigint           not null
#  invited_by_id :bigint
#  team_id       :integer
#
# Indexes
#
#  index_account_invitations_on_account_id     (account_id)
#  index_account_invitations_on_invited_by_id  (invited_by_id)
#  index_account_invitations_on_token          (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (invited_by_id => users.id)
#
class AccountInvitation < ApplicationRecord
  ROLES = AccountUser::ROLES

  include Rolified

  belongs_to :account
  belongs_to :invited_by, class_name: "User", optional: true
  has_secure_token

  # validates :name, :email, presence: true
  validates :email, uniqueness: {scope: :account_id, message: :invited}

  def save_and_send_invite
    save && send_invite
  end

  def send_invite
    AccountInvitationsMailer.with(account_invitation: self).invite.deliver_later
  end

  def accept!(user)
    user.team_id = team_id if team_id.present?
    user.invitation_accepted_at = DateTime.now

    account_user = account.account_users.new(user: user, roles: roles)
    if account_user.valid?
      ApplicationRecord.transaction do
        account_user.save!
        destroy!
      end

      [account.owner, invited_by].uniq.each do |recipient|
        AcceptedInvite.with(account: account, user: user).deliver_later(recipient)
      end

      account_user
    else
      errors.add(:base, account_user.errors.full_messages.first)
      nil
    end
  end

  def reject!
    destroy
  end

  def to_param
    token
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.accessible_attributes
    ["email", "first_name", "last_name", "team_name", "roles"]
  end

  def self.sanitize_row_data(row, teams, roles)
    hashed_row = row.to_h

    teams.has_key?(hashed_row["team_name"]) ?
      hashed_row["team_id"] = teams[hashed_row["team_name"]] :
      hashed_row["team_name"] = nil

    hashed_row["roles"] = roles.map { |e| e.keys }.flatten.include?(hashed_row["roles"]) ? {hashed_row["roles"] => true} : {"member" => true}

    hashed_row
  end

  def self.persist_records(records)
    records.each_slice(5) do |slice|
      slice.each do |object|
        object.save_and_send_invite
      end
      sleep(3)
    end
  end

  def self.import_file(file_name, account)
    if Rails.env.production?
    else
      # file_stream_or_path = account.users_uploaded_file_path
      BulkImportUsersJob.perform_later(file_name, account)
    end
  end
end
