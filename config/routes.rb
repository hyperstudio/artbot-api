Rails.application.routes.draw do
  devise_for :users

  resources :registrations, only: [:create]
  
  ActiveAdmin.routes(self)
  root to: 'events#index'

  get '/profiles/dashboard' => 'profiles#dashboard', :as => :user_root

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

  resources :events, only: [:show, :index] do
    resource :favorite, only: [:create]
  end

  resources :locations, only: [:index, :show] do
    resources :events, only: [:index]
  end

  resources :tokens, only: [:create]
end
