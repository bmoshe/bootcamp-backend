# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::LogIn, type: :graphql_mutation do
  let(:context) { { current_session: nil } }
  let(:mutation) { described_class.new(object: nil, context: context) }

  describe '#resolve' do
    let(:input) { build(:log_in_input) }

    subject { mutation.resolve(input: input) }

    it 'creates a new session' do
      expect { subject }.to change { Session.count }.by(1)
    end

    it 'returns a Hash containing the Session' do
      should be_a(Hash)
      expect(subject[:session]).to be_a(Session)
      expect(subject[:errors]).to be_empty
    end

    context 'when the credentials are incorrect' do
      let(:input) { build(:log_in_input, password: 'wrong-password') }

      it 'raises an ActiveRecord::RecordNotSaved error' do
        expect do
          expect { subject }.to raise_error(ActiveRecord::RecordNotSaved)
        end.not_to change { Session.count }
      end
    end
  end
end
