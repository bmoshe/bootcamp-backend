# frozen_string_literal: true

class Mutations::LogOut < Mutations::BaseMutation
  field :success, Boolean, null: true
  field :errors, [String], null: false

  def resolve
    authorize(Session, :destroy?)
    current_session.destroy!

    { success: true, errors: [] }
  end
end
