# frozen_string_literal: true

class Types::LogInInputType < Types::BaseInputObject
  argument :email, String, required: false
  argument :password, String, required: false
end
