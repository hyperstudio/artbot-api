Rails.application.routes.draw do
  devise_for :users

  post :registrations, to: 'registrations#create'
  get :registrations, to: 'registrations#show'

  patch :preferences, to: 'preferences#update'
  put :preferences, to: 'preferences#update'
  get :preferences, to: 'preferences#show'

  resources :possible_interests, only: [:index]
  resources :interests, only: [:index, :create, :destroy]

  resources :favorites, only: [:index, :destroy, :update] do
    collection do
      get 'history'
    end
  end

  resources :discoveries, only: [:index]

  resources :profiles, :only => [:dashboard]

  resources :events, only: [:show, :index], defaults: { format: 'json' } do
    resource :favorite, only: [:create]
  end

  resources :locations, only: [:index, :show], defaults: { format: 'json' } do
    resources :events, only: [:index]
  end

  resources :tokens, only: [:create]

  ActiveAdmin.routes(self)
end
