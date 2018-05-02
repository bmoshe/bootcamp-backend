# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pundit

  # Here we catch errors commonly thrown by our controllers, and gracefully inform the client of their transgressions.
  # More specifically, authorization errors from Pundit are translated into their respective HTTP headers,
  # and ActiveRecord errors rendered into something that can be displayed to the user.

  rescue_from(Pundit::NotAuthorizedError) do
    head current_user.nil? ? :unauthorized : :forbidden
  end

  rescue_from(ActiveRecord::RecordNotFound) do |error|
    render json: { errors: { (error.model || 'Object') => ['not found'] } }, status: :not_found
  end

  rescue_from(ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved, ActiveRecord::RecordNotDestroyed) do |error|
    render json: { errors: error.record.errors }, status: :unprocessable_entity
  end

  # This is the app's authentication logic. It tries to fetch an active Session using a secure token.
  # The app expects a session token to be passed in the `Session-Token` header.

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
