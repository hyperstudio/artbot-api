Rails.application.routes.draw do

  root to: 'home#index'
  get '/profiles/dashboard' => 'profiles#dashboard', :as => :user_root

  devise_for :users, :path_names => {:sign_in => "login", :sign_out => "logout"}, :path => 'd'

  resources :profiles, :only => [:dashboard]
  resources :events do
    resource :favorite, only: [:create]
  end
  resources :locations
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
