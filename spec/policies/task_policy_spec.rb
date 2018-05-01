# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskPolicy do
  let(:user) { User.new }
  let(:task) { Task.new(user: user) }

  subject { described_class }

  permissions :index? do
    it "doesn't permit guests to list tasks" do
      should_not permit(nil, Task)
    end

    it 'permits users to list their tasks' do
      should permit(user, Task)
    end
  end

  permissions :show? do
    it "doesn't permit guests to view tasks" do
      should_not permit(nil, task)
    end

    it 'permits users to view their own tasks' do
      should permit(user, task)
    end

    it "doesn't permit users to view tasks they don't own" do
      task.user = User.new
      should_not permit(user, task)
    end
  end

  permissions :create? do
    it "doesn't permit guests to create tasks" do
      should_not permit(nil, Task)
    end

    it 'permits users to create their tasks' do
      should permit(user, Task)
    end
  end

  permissions :update? do
    it "doesn't permit guests to edit tasks" do
      should_not permit(nil, task)
    end

    it 'permits users to edit their own tasks' do
      should permit(user, task)
    end

    it "doesn't permit users to edit tasks they don't own" do
      task.user = User.new
      should_not permit(user, task)
    end
  end

  permissions :destroy? do
    it "doesn't permit guests to delete tasks" do
      should_not permit(nil, task)
    end

    it 'permits users to delete their own tasks' do
      should permit(user, task)
    end

    it "doesn't permit users to delete tasks they don't own" do
      task.user = User.new
      should_not permit(user, task)
    end
  end
end
