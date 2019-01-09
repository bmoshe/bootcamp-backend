# frozen_string_literal: true

class Types::MutationType < Types::BaseObject
  field :log_in, mutation: Mutations::LogIn
  field :log_out, mutation: Mutations::LogOut
end
