class Post < ApplicationRecord
  belongs_to :user
  validates :content, length: { in: 1..140 }
end
