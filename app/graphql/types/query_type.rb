# frozen_string_literal: true

class Types::QueryType < Types::BaseObject
  field :current_session, resolver: Queries::CurrentSession
  field :tags, resolver: Queries::Tags
end