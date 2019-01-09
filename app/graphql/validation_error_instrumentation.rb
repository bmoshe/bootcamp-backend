# frozen_string_literal: true

class ValidationErrorInstrumentation
  MUTATION_TYPE = 'Mutation'

  def instrument(type, field)
    return field if type.name != MUTATION_TYPE

    old_resolve_proc = field.resolve_proc
    new_resolve_proc = proc { |object, arguments, context|
      begin
        old_resolve_proc.call(object, arguments, context)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved, ActiveRecord::RecordNotDestroyed => error
        build_validation_errors(error.record.errors)
      end
    }

    field.redefine { resolve(new_resolve_proc) }
  end

private

  def build_validation_errors(errors)
    { errors: errors.full_messages }
  end
end
