# frozen_string_literal: true

class Types::QueryType < Types::BaseObject
  field :current_session, resolver: Queries::CurrentSession
  field :current_user, resolver: Queries::CurrentUser

  field :tags, resolver: Queries::Tags
end
