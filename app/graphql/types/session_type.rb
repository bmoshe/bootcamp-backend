# frozen_string_literal: true

class Types::SessionType < Types::BaseObject
  field :token, String, null: false
  field :expires_at, Types::DateTimeType, null: false
  field :user, Types::UserType, null: false
end
