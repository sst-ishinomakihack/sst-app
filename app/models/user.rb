class User < ApplicationRecord
  has_many :posts
  accepts_nested_attributes_for :posts, allow_destroy: true
  before_save { email.downcase! }

  has_secure_password

  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def self.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
end
