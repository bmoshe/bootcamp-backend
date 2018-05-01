# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  let(:current_user) { create(:user) }
  let(:current_session) { create(:session, user: current_user) }
  let(:task) { create(:task, user: current_user) }

  before(:each) do
    request.headers['Session-Token'] = current_session.token
  end

  describe 'GET #index' do
    let!(:tasks) { create_list(:task, 3, user: current_user) }

    it 'returns a list of tasks' do
      get :index

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #show' do
    it 'returns the requested task' do
      get :show, params: { id: task.id }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    it 'creates a new task owned by the current user' do
      expect do
        post :create, params: { task: attributes_for(:task) }

        expect(response).to have_http_status(:created)
      end.to change { Task.count }.by(1)
      expect(Task.last.user).to eq(current_user)
    end
  end

  describe 'PATCH #update' do
    it 'marks a task as completed' do
      expect do
        patch :update, params: { id: task.id, task: { completed: true } }

        expect(response).to have_http_status(:ok)
      end.to change { task.reload.completed }.to(true)
    end
  end

  describe 'DELETE #destroy' do
    let!(:task) { create(:task, user: current_user) }

    it 'deletes an existing task' do
      expect do
        delete :destroy, params: { id: task.id }

        expect(response).to have_http_status(:no_content)
      end.to change { Task.count }.by(-1)
    end
  end
end
