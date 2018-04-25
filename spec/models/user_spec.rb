# frozen_string_literal: true
# == Schema Information
#
# Table name: users
#
#  id              :bigint(8)        not null, primary key
#  email           :citext           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  it 'has a valid factory' do
    should be_valid
  end

  it 'is invalid without an email' do
    subject.email = nil
    should be_invalid
  end

  it 'is invalid when a user exists with the same email' do
    create(:user, email: subject.email)
    should be_invalid
  end

  it 'is invalid without a password' do
    subject.password = nil
    should be_invalid
  end
end
