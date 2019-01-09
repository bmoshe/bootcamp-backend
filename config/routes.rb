# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resource :session, only: %i[show create destroy]
  resources :tags, only: :index

  post '/graphql', to: 'graphql#execute'
end
