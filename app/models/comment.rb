class Comment < ActiveRecord::Base
  attr_accessible :comment_content, :post_id, :user_id

  validates_presence_of :comment_content

  belongs_to :post
  belongs_to :user
  attr_accessible :post_attributes
  accepts_nested_attributes_for :post
end
