# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  describe 'GET #index' do
    let!(:tags) { create_list(:tag, 3).sort_by(&:name) }

    it 'returns a list of tags ordered by their name' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(tags: tags.map { |tag| { id: tag.id } })
    end

    it 'searches for matching tags when provided with a query parameter' do
      tag = tags.first
      get :index, params: { query: tag.name }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(tags: [id: tag.id])
    end
  end
end
