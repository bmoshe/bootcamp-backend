# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :set_task, only: %i[show update destroy]

  def index
    @tasks = policy_scope(Task)
    render json: @tasks
  end

  def show
    authorize(@task)
    render json: @task
  end

  def create
    @task = authorize(Task).create!(task_params) do |task|
      task.user = current_user
    end
    render json: @task, status: :created
  end

  def update
    authorize(@task).update!(task_params)
    render json: @task
  end

  def destroy
    authorize(@task).destroy!
  end

private

  def task_params
    params.require(:task).permit(:name, :completed)
  end

  def set_task
    @task = Task.find(params[:id])
  end
end
