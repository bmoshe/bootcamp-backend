# frozen_string_literal: true

class SessionPolicy < ApplicationPolicy
  # These methods correlate to the action methods in the `SessionsController`.
  # They return either `true` or `false` to indicate whether the current action is allowed.
  # For example, `create?` requires the current User to be `nil`, so that you can't
  # login a second time, once you've already logged in.
  #
  # See more: https://github.com/varvet/pundit#policies

  # Users are allowed to view the current Session when they're logged in.
  # If there's no session, there's nothing for them to view anyway!
  def show?
    current_user.present?
  end

  # Guests (clients without a Session) are allowed to create a new Session (log in).
  # Once you're already logged in, you shouldn't be able to do so until you log out!
  def create?
    current_user.nil?
  end

  # Users are allowed to destroy their current Session. This logs them out.
  # If there's no session, there's nothing to log out of anyway.
  def destroy?
    current_user.present?
  end

  # This defines the attributes that we accept when creating the record.
  # Rails uses strong parameter validation to filter out any attributes that aren't defined
  # within this list.
  #
  # This is important for security, so that the client isn't able to send a `user_id`
  # and create Sessions for whichever User they want.
  #
  # See more:
  #  - https://github.com/varvet/pundit#strong-parameters
  #  - http://edgeguides.rubyonrails.org/action_controller_overview.html#strong-parameters
  def permitted_attributes
    %i[email password]
  end
end
