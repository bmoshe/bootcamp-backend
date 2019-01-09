# frozen_string_literal: true

FactoryBot.define do
  factory :log_in_input, class: OpenStruct do
    email { user.email }
    password { user.password }

    transient do
      user { create(:user) }
    end
  end
end
