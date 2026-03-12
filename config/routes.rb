Rails.application.routes.draw do
  # Root path - homepage
  root "home#index"

  # Basic pages
  get "community", to: "community#index"
  get "chat", to: "chat#index"
  get "profile", to: "profile#index"
  get "sell", to: "listings#new"
  get 'login', to: 'login#index'
  
  # Listings routes (basic CRUD for now)
  resources :listings, only: [:index, :show, :new, :create]
  
  # Search route
  get "search", to: "listings#index"
end