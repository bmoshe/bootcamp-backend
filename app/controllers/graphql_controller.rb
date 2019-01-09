# frozen_string_literal: true

class GraphqlController < ApplicationController
  def execute
    result = TodoApiSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  end

private

  def query
    params[:query]
  end

  def variables
    parse_variables(params[:variables])
  end

  def operation_name
    params[:operationName]
  end

  def context
    { current_session: current_session }
  end

  # Handle form data, JSON body, or a blank value
  def parse_variables(ambiguous_param)
    case ambiguous_param
    when String
      ambiguous_param.present? ? parse_variables(JSON.parse(ambiguous_param)) : {}
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end
end
