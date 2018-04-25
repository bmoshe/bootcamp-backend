# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let!(:current_session) { create(:session) }

  before(:each) do
    request.headers['Session-Token'] = current_session.token
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #create' do
    let(:user) { create(:user) }

    before(:each) do
      request.headers['Session-Token'] = nil
    end

    it 'creates a new session' do
      expect do
        post :create, params: { session: { email: user.email, password: user.password } }
        expect(response).to have_http_status(:created)
      end.to change { Session.count }.by(1)
    end
  end

  describe 'GET #destroy' do
    it 'deletes the current session' do
      expect do
        delete :destroy
        expect(response).to have_http_status(:no_content)
      end.to change { Session.count }.by(-1)
    end
  end
end
