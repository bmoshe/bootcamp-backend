# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pundit

  # This is the app's authentication logic.
  # It tries to fetch an active Session using a session token.
  # The app expects the session token to be passed in a `Session-Token` header.

  def current_user
    current_session&.user
  end

  def current_session
    return @current_session if defined?(@current_session)
    @current_session = Session.active.find_by(token: session_token)
  end

private

  def session_token
    request.headers['Session-Token']
  end
end
