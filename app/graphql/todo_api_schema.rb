# frozen_string_literal: true

class TodoApiSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  instrument(:field, ErrorHandlingInstrumentation.new)
  instrument(:field, ValidationErrorInstrumentation.new)

  def self.resolve_type(_type, object, _context)
    "Types::#{object.class.name}Type".safe_constantize
  end
end
