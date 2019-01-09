# frozen_string_literal: true

class Mutations::LogIn < Mutations::BaseMutation
  argument :input, Types::LogInInputType, required: true

  field :session, Types::SessionType, null: true
  field :errors, [String], null: false

  def resolve(input:)
    authorize(Session, :create?)
    session = Session.create!(input.to_h)

    { session: session, errors: [] }
  end
end
