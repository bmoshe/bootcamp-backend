# frozen_string_literal: true

class SessionsController < ApplicationController
  # GET http://localhost:3000/session
  def show
    authorize(Session)
    render json: current_session
  end

  # POST http://localhost:3000/session
  def create
    authorize(Session)
    @session = Session.create!(permitted_attributes(Session))
    render json: @session, status: :created
  end

  # DELETE http://localhost:3000/session
  def destroy
    authorize(Session)
    current_session.destroy!
    head :no_content
  end
end
