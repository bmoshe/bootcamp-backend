# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Queries::Tags, type: :graphql_query do
  let(:context) { { current_session: nil } }
  let(:query) { described_class.new(object: nil, context: context) }

  describe '#resolve' do
    let!(:tags) { create_list(:tag, 3).sort_by(&:name) }

    subject { query.resolve }

    it 'returns a list of tags in order of name' do
      should eq(tags)
    end
  end
end
