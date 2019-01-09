# frozen_string_literal: true

class Queries::Tags < Queries::BaseQuery
  type [Types::TagType], null: false

  def resolve
    authorize(Tag, :index?)
    policy_scope(Tag).order(:name)
  end
end
