# frozen_string_literal: true

class Queries::CurrentSession < Queries::BaseQuery
  type Types::SessionType, null: true

  def resolve
    current_session
  end
end
