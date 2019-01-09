# frozen_string_literal: true

class Queries::BaseQuery < GraphQL::Schema::Resolver
  include SessionFromContext
end
