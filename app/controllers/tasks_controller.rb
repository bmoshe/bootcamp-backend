# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :set_task, only: %i[show update destroy]

  def index
    @tasks = Task.all
    render json: @tasks
  end

  def show
    render json: @task
  end

  def create
    @task = Task.create!(task_params) do |task|
      task.user = current_user
    end
    render json: @task, status: :created
  end

  def update
    @task.update!(task_params)
    render json: @task
  end

  def destroy
    @task.destroy!
  end

private

  def task_params
    params.require(:task).permit(:name, :completed)
  end

  def set_task
    @task = Task.find(params[:id])
  end
end
