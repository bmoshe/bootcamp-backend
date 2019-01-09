# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Queries::CurrentSession, type: :graphql_query do
  let(:session) { create(:session) }
  let(:context) { { current_session: session } }
  let(:query) { described_class.new(object: nil, context: context) }

  describe '#resolve' do
    subject { query.resolve }

    it 'returns the current session' do
      should eq(session)
    end

    context 'when there is no current session' do
      let(:session) { nil }

      it 'returns nil' do
        should be_nil
      end
    end
  end
end
