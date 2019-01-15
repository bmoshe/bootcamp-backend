# frozen_string_literal: true

class Queries::CurrentUser < Queries::BaseQuery
  type Types::UserType, null: true

  def resolve
    current_user
  end
end
