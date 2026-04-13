Rails.application.routes.draw do
  # Root path - listings page
  root "listings#index"

  # Basic pages
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
  get  "verify/:user_id/:token", to: "users#verify",        as: :verify_email
  post "verify/:user_id/:token", to: "users#confirm_verify", as: :confirm_verify_email
  post "verify/resend", to: "users#resend_verification", as: :resend_verification_email

  # Listings routes (basic CRUD for now)
  resources :listings, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]
  post "sell", to: "listings#create"
  get "listings/:id", to: "listings#show"
  get "listings", to: "listings#index"

  # Notification
  get 'chat/unread_counts', to: 'chat#unread_counts'
  post 'chat/update_unread_count', to: 'chat#update_unread_count'
  
  # Main chat routes
  get 'chat', to: 'chat#index', as: 'chat'
  get 'chat/:user_id', to: 'chat#show', as: 'chat_with_user'
  get 'chat/:user_id/messages', to: 'chat#messages', as: 'chat_messages'
  post 'chat/:user_id/send_message', to: 'chat#send_message', as: 'chat_send_message'

  # Community route
  resources :community_posts, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    resources :comments, only: [ :create, :destroy ]
  end

  get "/community", to: "community_posts#index", as: :community

  # Admin routes
  namespace :admin do
    get "dashboard", to: "dashboard#index"
    post "users/:id/ban", to: "dashboard#ban_user", as: :ban_user
    post "users/:id/unban", to: "dashboard#unban_user", as: :unban_user
    delete "users/:id", to: "dashboard#delete_user", as: :delete_user
    delete "listings/:id", to: "dashboard#delete_listing", as: :delete_listing
    delete "posts/:id", to: "dashboard#delete_post", as: :delete_post
  end
end
