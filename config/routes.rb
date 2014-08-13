Rails.application.routes.draw do
  devise_for :users

  resources :registrations, only: [:create]

  patch :preferences, to: 'preferences#update'
  put :preferences, to: 'preferences#update'
  get :preferences, to: 'preferences#show'

  resources :favorites, only: [:index, :show, :destroy] do
    collection do
      get 'history'
    end
  end

  resources :profiles, :only => [:dashboard]

  resources :events do
    resource :favorite, only: [:create]
  end

  resources :locations, only: [:index, :show] do
    resources :events, only: [:index]
  end

  resources :entities do
    collection do
      get 'import'
      post 'import'
    end
  end

  resources :tokens, only: [:create]
end
