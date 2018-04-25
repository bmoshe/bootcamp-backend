# frozen_string_literal: true

class SessionsController < ApplicationController
  def show
    authorize(Session)
    render json: current_session
  end

  def create
    authorize(Session)
    @session = Session.create!(permitted_attributes(Session))
    render json: @session, status: :created
  end

  def destroy
    authorize(Session)
    current_session.destroy!
    head :no_content
  end
end
