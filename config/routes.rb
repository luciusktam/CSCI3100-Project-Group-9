Rails.application.routes.draw do
  # Root path - homepage
  root "home#index"

  # Basic pages
  get "community", to: "community#index"
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
  resources :users, only: [:show, :new, :create]
  get  "verify/:token", to: "users#verify", as: :verify_email
  post "verify/resend", to: "users#resend_verification", as: :resend_verification_email

  # Listings routes (basic CRUD for now)
  resources :listings, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]
  post "sell", to: "listings#create"
  get "listings/:id", to: "listings#show"
  get "listings", to: "listings#index"

  # Chat route
  get 'chat', to: 'chat#index'
  get 'chat/:user_id', to: 'chat#show', as: 'chat_with_user'
  get 'chat/:user_id/messages', to: 'chat#messages'
  post 'chat/:user_id/send_message', to: 'chat#send_message'
  get 'chat/unread_counts', to: 'chat#unread_counts'
  resources :chat, only: [:index, :show] do
    member do
      post 'send_message'
      get 'messages'
    end
  end
end
