# == Schema Information
#
# Table name: blogs
#
#  id         :bigint           not null, primary key
#  published  :boolean          default(FALSE)
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Blog < ApplicationRecord
  validates_presence_of :title
  
  has_rich_text :body
  acts_as_taggable_on :tags
end
