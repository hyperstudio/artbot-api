Rails.application.routes.draw do

  root to: 'home#index'

  get '/profiles/dashboard' => 'profiles#dashboard', :as => :user_root
  devise_for :users
  resources :profiles, :only => [:dashboard]

  resources :events

  resources :locations do
    resources :events
  end

  get '/events/:date' => 'events#index'

  resources :favorites
  resources :attendances
  resources :interests

  resources :entities do
    collection do
      get 'import'
      post 'import'
    end
  end

  namespace :admin do
    get '/' => 'users#index'
    resources :users
  end
end
