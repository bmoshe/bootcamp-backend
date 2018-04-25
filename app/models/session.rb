# frozen_string_literal: true
# == Schema Information
#
# Table name: sessions
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  token      :string           not null
#  expires_at :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sessions_on_token    (token) UNIQUE
#  index_sessions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Session < ApplicationRecord
  # These are transient attributes. They exist on the model, but not in the database.
  # We use these to find and authenticate the User when logging in.
  # See more: http://api.rubyonrails.org/classes/ActiveRecord/Attributes/ClassMethods.html#method-i-attribute
  attribute :email, :string
  attribute :password, :string

  belongs_to :user, optional: true

  # We require an email address and password to login. Here we validate that the email and password
  # are present (not nil or empty) when the Session is being created.
  validates :email, :password, presence: { on: :create }

  # The Session uses a unique, secure token to handle authentication with the frontend.
  # Rails provides built-in functionality to automatically generate secure tokens.
  # See more: http://api.rubyonrails.org/classes/ActiveRecord/SecureToken/ClassMethods.html#method-i-has_secure_token
  has_secure_token

  # Rails models expose callbacks that allow for code to be run as part of the model be saved.
  # Here we're calling methods before the model is created (INSERT'ed into the database).
  # See more: http://guides.rubyonrails.org/active_record_callbacks.html#callbacks-overview
  before_create :set_user_from_credentials, if: -> { user.nil? }
  before_create :set_expires_at, if: -> { expires_at.nil? }

private

  def set_user_from_credentials
    # Find a User using the given email, and attempt to authenticate if the User was found.
    # Since `.authenticate(...)` returns `false` on failure, we're coercing the result to `nil`.
    # If either part of the process fails, set an error on the model and abort the save.
    self.user = User.find_by(email: email)&.authenticate(password) || nil
    errors.add(:base, 'Email or password is incorrect') && throw(:abort) if user.nil?
  end

  def set_expires_at
    self.expires_at = 3.months.from_now
  end
end
