# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :current_user
  attr_reader :record

  def initialize(current_user, record)
    @current_user = current_user
    @record       = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  class Scope
    attr_reader :current_user
    attr_reader :scope

    def initialize(current_user, scope)
      @current_user = current_user
      @scope        = scope
    end

    def resolve
      scope
    end
  end
end
