# frozen_string_literal: true

class Types::DateTimeType < Types::BaseScalar
  graphql_name 'DateTime'
  description <<~DOC.strip
    The `DateTime` scalar type represents a specific date and time,
    transmitted as an ISO-8601 string (including fractional seconds).
  DOC

  class << self
    def coerce_input(input_value, _context)
      Time.zone.parse(input_value) || raise_coercion_error!(input_value)
    rescue ArgumentError
      raise_coercion_error!(input_value)
    end

    def coerce_result(ruby_value, _context)
      ruby_value.as_json
    end

  private

    def raise_coercion_error!(input_value)
      raise GraphQL::CoercionError, "`#{input_value.inspect}` is not a valid DateTime"
    end
  end
end
