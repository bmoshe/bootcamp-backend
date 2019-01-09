# frozen_string_literal: true

class TagsController < ApplicationController
  def index
    @tags = policy_scope(Tag.all)
    @tags = @tags.search_by_name(params[:query]) if params[:query].present?
    @tags = @tags.order(:name)

    render json: @tags
  end
end
