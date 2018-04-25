# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pundit

  def current_user
    current_session&.user
  end

  def current_session
    return @current_session if defined?(@current_session)
    @current_session = Session.find_by(token: session_token)
  end

private

  def session_token
    request.headers['Session-Token']
  end
end
