# frozen_string_literal: true

class SessionsController < ApplicationController
  def show
    authorize(current_session)
    render json: current_session
  end

  def create
    authorize(Session)
    @session = Session.create!(permitted_attributes(Session))
    render json: @session, status: :created
  end

  def destroy
    authorize(current_session)
    current_session.destroy!
    head :no_content
  end
end
