Rails.application.routes.draw do
  # Root path - homepage
  root "home#index"

  # Basic pages
  get "community", to: "community#index"
  get "chat", to: "chat#index"
  get "profile", to: "profile#index"
  patch "profile", to: "profile#update"
  delete "profile", to: "profile#destroy", as: :delete_profile
  get "sell", to: "listings#new"
  get "login", to: "login#index"
  get "register", to: "users#new"
  get "forgot_password", to: "passwords#new"
  post "forgot_password", to: "passwords#create"
  get "reset_password/:token", to: "passwords#edit", as: :edit_password
  patch "reset_password/:token", to: "passwords#update", as: :update_password
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  resources :users, only: [:new, :create]
  get  "verify/:token", to: "users#verify", as: :verify_email
  post "verify/resend", to: "users#resend_verification", as: :resend_verification_email

  # Listings routes (basic CRUD for now)
  resources :listings, only: [:index, :show, :new, :create]
  
  # Search route
  get "search", to: "listings#index"
end