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

class Organization < Account
  # Broadcast changes in realtime with Hotwire
  after_create_commit -> { broadcast_prepend_later_to :organizations, partial: "organizations/index", locals: {organization: self} }
  after_update_commit -> { broadcast_replace_later_to self }
  after_destroy_commit -> { broadcast_remove_to :organizations, target: dom_id(self, :index) }
end
