# frozen_string_literal: true

module SessionFromContext
  def current_session
    context[:current_session]
  end

  def current_user
    current_session&.user
  end

  def policy(record)
    Pundit.policy!(current_user, record)
  end

  def policy_scope(record)
    Pundit.policy_scope!(current_user, record)
  end

  def permit?(record, query)
    policy(record).send(query)
  end

  def authorize(record, query)
    return record if permit?(record, query)

    raise Pundit::NotAuthorizedError.new(policy: policy(record), record: record, query: query)
  end
end
