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

  # This is a relationship we define between this `Session` and a `User` that owns it.
  # Rails automatically infers that this refers to the User model, and uses the `user_id` column
  # based on the name of the association.
  #
  # This association creates a `user` method on the Session, which Rails manages for us.
  # It takes care of loading the User from the database:
  #
  #  session.user == User.find(session.user_id)
  #
  # Rails also automatically sets the `user_id` attribute when we assign a value to the association.
  #
  #  session.user = User.find(1)
  #  session.user_id # => 1
  #
  # We define that the association is `optional` because we have our own logic that assigns it,
  # and Rails validates that `belongs_to` associations are not `nil` by default.
  # See more: http://guides.rubyonrails.org/association_basics.html#the-belongs-to-association
  belongs_to :user, optional: true

  # We require an email address and password to login. Here we define validates to ensure that
  # the email and password are present (not nil or empty) when the Session is being created.
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

  # Scopes are a neat Rails feature which lets you wrap commonly used portions of queries in a method.
  # They can be chained together, and make testing and keeping code clean much easier.
  # For example, if you wanted to see all of the `active` Sessions:
  #
  #  Session.active # => #<ActiveRecord::Relation [...]>
  #
  # See more: http://guides.rubyonrails.org/active_record_querying.html#scopes
  scope :active, -> { where('sessions.expires_at > ?', Time.current) }

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
