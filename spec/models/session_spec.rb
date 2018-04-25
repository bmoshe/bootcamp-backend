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

RSpec.describe Session, type: :model do
  subject { build(:session) }

  it 'has a valid factory' do
    should be_valid
  end

  it 'is invalid without an email' do
    subject.email = nil
    should be_invalid
  end

  it 'is invalid without a password' do
    subject.password = nil
    should be_invalid
  end

  it 'sets the user using the email and password when created' do
    user = create(:user)
    subject.user = nil
    subject.email = user.email
    subject.password = user.password

    expect do
      expect(subject.save).to be_truthy
    end.to change { subject.user }.to(user)
  end

  it "doesn't assign a user, and aborts the save when the password is incorrect" do
    user = create(:user)
    subject.user = nil
    subject.email = user.email
    subject.password = 'incorrect-password'

    expect do
      expect(subject.save).to be_falsey
    end.not_to change { subject.user }
  end

  it 'sets an expires-at timestamp when created' do
    expect { subject.save }.to change { subject.expires_at }.to be_present
  end

  describe '#active' do
    let(:session) { create(:session, expires_at: 3.hours.from_now) }

    subject { Session.active }

    it 'includes sessions that expire in the future' do
      should include(session)
    end

    it "doesn't include sessions that have already expired" do
      session.update(expires_at: 3.hours.ago)
      should_not include(session)
    end
  end
end
