# frozen_string_literal: true

class SessionPolicy < ApplicationPolicy
  # These methods correlate to the action methods in the `SessionsController`.
  # They return either `true` or `false` to indicate whether the current action is allowed.
  # For example, `create?` requires the current User to be `nil`, so that you can't
  # login a second time, once you've already logged in.
  #
  # See more: https://github.com/varvet/pundit#policies

  def show?
    current_user.present?
  end

  def create?
    current_user.nil?
  end

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
