Rails.application.routes.draw do

  get '/profiles/dashboard' => 'profiles#dashboard', :as => :user_root

  devise_for :users

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
