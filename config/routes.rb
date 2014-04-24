Rails.application.routes.draw do
  root 'events#index'
  get 'events', to: 'events#index'
  get 'events/:id', to: 'events#show'
  get 'locations', to: 'locations#index'
  get 'locations/:id', to: 'locations#show'
end
