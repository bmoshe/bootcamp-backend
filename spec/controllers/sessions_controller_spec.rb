# frozen_string_literal: true
# == Schema Information
#
# Table name: sessions
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  token      :string           not null
#  expires_at :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sessions_on_token    (token) UNIQUE
#  index_sessions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:current_user) { create(:user) }
  let(:current_session) { create(:session, user: current_user) }

  before(:each) do
    # The Session-Token header is what controls which user is logged-in.
    # This is implemented in `app/controllers/application_controller.rb`.
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
      # Clear the Session-Token header.
      # This logs the current User out.
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
