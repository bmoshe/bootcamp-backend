# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionPolicy do
  let(:user) { User.new }
  let(:session) { Session.new(user: user) }

  subject { described_class }

  permissions :show? do
    it "doesn't permit guests to view sessions" do
      should_not permit(nil, session)
    end

    it 'permits users to view sessions' do
      should permit(user, session)
    end
  end

  permissions :create? do
    it 'permits guests to create sessions' do
      should permit(nil, Session)
    end

    it "doesn't permit users to create sessions" do
      should_not permit(user, Session)
    end
  end

  permissions :destroy? do
    it "doesn't permit guests to delete sessions" do
      should_not permit(nil, Session)
    end

    it 'allows users to delete sessions' do
      should permit(user, session)
    end
  end
end
