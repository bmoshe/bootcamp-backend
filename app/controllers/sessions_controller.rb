# frozen_string_literal: true

class SessionsController < ApplicationController
  # GET http://localhost:3000/session
  # This action allows the client to view the current session.
  # Upon success, this returns a Session as JSON with HTTP status 200 (OK).
  def show
    authorize(Session)
    render json: current_session
  end

  # POST http://localhost:3000/session
  # This is the `log in` action. It creates a new session in the database using parameters from the client.
  # We use `permitted_attributes` to filter incoming parameters. This function calls the `permitted_attributes`
  # function defined in `app/policies/session_policy.rb`, which returns a list of attributes to allow.
  # Upon success, this returns a Session as JSON with HTTP status 201 (Created).
  def create
    authorize(Session)
    @session = Session.create!(permitted_attributes(Session))
    render json: @session, status: :created
  end

  # DELETE http://localhost:3000/session
  # This is the `log out` action. It deletes the current session from the database,
  # which will log the current user out (since their session is no longer valid).
  # Upon success, this method returns an empty body with HTTP status 204 (No Content).
  def destroy
    authorize(Session)
    current_session.destroy!
    head :no_content
  end
end
