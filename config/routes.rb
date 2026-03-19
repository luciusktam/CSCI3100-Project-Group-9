Rails.application.routes.draw do
  # Root path - homepage
  root "home#index"

  # Basic pages
  get "community", to: "community#index"
  get "chat", to: "chat#index"
  get "profile", to: "profile#index"

  get "sell", to: "listings#new"
  get "login", to: "login#index"
  get "register", to: "users#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  resources :users, only: [ :new, :create ]
  get "verify/:token", to: "users#verify", as: :verify_email

  # Listings routes (basic CRUD for now)
  resources :listings, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]
  post "sell", to: "listings#create"
  get "listings/:id", to: "listings#show"
  get "listings", to: "listings#index"

  # Search route
end
