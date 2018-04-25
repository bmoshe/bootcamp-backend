# frozen_string_literal: true
# == Schema Information
#
# Table name: users
#
#  id              :bigint(8)        not null, primary key
#  email           :citext           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

class User < ApplicationRecord
  # Validate the user's email is not blank (nil or empty), and that it is unique.
  # See more: http://guides.rubyonrails.org/active_record_validations.html#presence
  validates :email, presence: true, uniqueness: true

  # Rails has built-in logic to hash and validate passwords. The hashed password is stored in `password_digest`.
  # This also creates in-memory attributes (not stored in DB) called `password` and `password_confirmation`.
  # We can assign these attributes when creating a User, and Rails will validate them, and hash the password:
  #
  #  user = User.new(password: 'secure-123', password_confirmation: 'secure-123')
  #  user.password_digest # => "$2a$10$..."
  #
  # Rails also provides functions for verifying the password that's set on the User:
  #
  #  user.authenticate('secure-123') # => <User:...>
  #  user.authenticate('incorrect!') # => false
  #
  # See more: http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password
  has_secure_password
end
