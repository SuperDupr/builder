# == Schema Information
#
# Table name: accounts
#
#  id                  :bigint           not null, primary key
#  account_users_count :integer          default(0)
#  active              :boolean          default(TRUE)
#  billing_email       :string
#  domain              :string
#  extra_billing_info  :text
#  name                :string           not null
#  personal            :boolean          default(FALSE)
#  subdomain           :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  owner_id            :bigint
#
# Indexes
#
#  index_accounts_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#

class Account < ApplicationRecord
  RESERVED_DOMAINS = [Jumpstart.config.domain]
  RESERVED_SUBDOMAINS = %w[app help support]

  belongs_to :owner, class_name: "User", optional: true
  has_many :account_invitations, dependent: :destroy
  has_many :account_users, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :users, through: :account_users
  has_many :addresses, as: :addressable, dependent: :destroy
  has_one :billing_address, -> { where(address_type: :billing) }, class_name: "Address", as: :addressable
  has_one :shipping_address, -> { where(address_type: :shipping) }, class_name: "Address", as: :addressable

  has_many :industries, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :stories, dependent: :destroy
  has_many :blog_shares, dependent: :destroy
  has_many :shared_blogs, through: :blog_shares, source: :blog

  scope :personal, -> { where(personal: true) }
  scope :impersonal, -> { where(personal: false) }
  scope :sorted, -> { order(personal: :desc, name: :asc) }
  scope :active, -> { where(active: true) }

  has_noticed_notifications
  has_one_attached :avatar
  # ActiveStorage attachment for handling users file upload
  has_one_attached :users_file_upload
  pay_customer stripe_attributes: :stripe_attributes

  validates :avatar, resizable_image: true
  validates :name, presence: true

  # To require a domain or subdomain, add the presence validation
  validates :domain, exclusion: {in: RESERVED_DOMAINS, message: :reserved}, uniqueness: {allow_blank: true}
  validates :subdomain, exclusion: {in: RESERVED_SUBDOMAINS, message: :reserved}, format: {with: /\A[a-zA-Z0-9]+[a-zA-Z0-9\-_]*[a-zA-Z0-9]+\Z/, message: :format, allow_blank: true}, uniqueness: {allow_blank: true}

  def find_or_build_billing_address
    billing_address || build_billing_address
  end

  # Email address used for Pay customers and receipts
  # Defaults to billing_email if defined, otherwise uses the account owner's email
  def email
    billing_email? ? billing_email : owner&.email
  end

  def impersonal?
    !personal?
  end

  def personal_account_for?(user)
    personal? && owner_id == user.id
  end

  def owner?(user)
    owner_id == user.id
  end

  # An account can be transferred by the owner if it:
  # * Isn't a personal account
  # * Has more than one user in it
  def can_transfer?(user)
    impersonal? && owner?(user) && users.size >= 2
  end

  # Transfers ownership of the account to a user
  # The new owner is automatically granted admin access to allow editing of the account
  # Previous owner roles are unchanged
  def transfer_ownership(user_id)
    previous_owner = owner
    account_user = account_users.find_by!(user_id: user_id)
    user = account_user.user

    ApplicationRecord.transaction do
      account_user.update!(admin: true)
      update!(owner: user)

      # Add any additional logic for updating records here
    end

    # Notify the new owner of the change
    Account::OwnershipNotification.with(account: self, previous_owner: previous_owner).deliver_later(user)
  rescue
    false
  end

  # Used for per-unit subscriptions on create and update
  # Returns the quantity that should be on the subscription
  def per_unit_quantity
    account_users_count
  end

  def users_uploaded_file_name
    users_file_upload.filename.to_json
  end

  def users_uploaded_file_path
    ActiveStorage::Blob.service.send(:path_for, users_file_upload.key)
  end

  def self.open_spreadsheet(file_stream_or_path, file_name)
    if Rails.env.production?
    else
      case File.extname(file_name)
      when ".xls"
        Roo::Excel.new(file_stream_or_path, packed: nil, file_warning: :ignore)
      when ".xlsx"
        Roo::Excelx.new(file_stream_or_path, packed: nil, file_warning: :ignore)
      else
        raise "Unknown file type: #{file_name}"
      end
    end
  end

  def self.parse_spreadsheet(spreadsheet, file_name, account)
    last_row = spreadsheet.last_row
    init_account_invitations = []
    valid_teams = account.teams.pluck(:name, :id).to_h
    valid_roles = [{"member" => true}, {"admin" => true}]

    (2..last_row).each_with_index do |r, i|
      row = [AccountInvitation.accessible_attributes, spreadsheet.row(r).first(5)].transpose.to_h

      hashed_row = AccountInvitation.sanitize_row_data(row, valid_teams, valid_roles)

      account_invitation = account.account_invitations.new
      account_invitation.attributes = hashed_row
      account_invitation.invited_by = account.owner
      account_invitation.imported = true

      init_account_invitations << account_invitation if account_invitation.valid?
    end

    AccountInvitation.persist_records(init_account_invitations)
  end

  private

  # Attributes to sync to the Stripe Customer
  def stripe_attributes(*args)
    {address: billing_address&.to_stripe}.compact
  end
end
