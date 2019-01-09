# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::LogOut, type: :graphql_mutation do
  let!(:session) { create(:session) }
  let(:context) { { current_session: session } }
  let(:mutation) { described_class.new(object: nil, context: context) }

  describe '#resolve' do
    subject { mutation.resolve }

    it 'deletes the requested session' do
      expect { subject }.to change { Session.count }.by(-1)
      expect { session.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns a Hash containing a `success` flag' do
      should be_a(Hash)
      expect(subject[:success]).to be(true)
      expect(subject[:errors]).to be_empty
    end
  end
end
