# frozen_string_literal: true

class Mutations::BaseMutation < GraphQL::Schema::Mutation
  include SessionFromContext
end
