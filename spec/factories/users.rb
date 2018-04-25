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

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| Faker::Internet.email("#{Faker::Name.name}-#{n}") }
    password { Faker::Internet.password }
  end
end
