# frozen_string_literal: true

class TaskPolicy < ApplicationPolicy
  alias task record

  def index?
    current_user.present?
  end

  def show?
    current_user == task.user
  end

  def create?
    current_user.present?
  end

  def update?
    current_user == task.user
  end

  def destroy?
    current_user == task.user
  end

  def permitted_attributes
    %i[name completed]
  end

  class Scope < Scope
    def resolve
      return scope.none if current_user.nil?
      scope.where(user: current_user)
    end
  end
end
