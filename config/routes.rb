Rails.application.routes.draw do
  # Set root to home#index
  root "home#index"

  # If you have PWA routes, keep them:
  # get "up" => "rails/health#show", as: :rails_health_check
  # get 'service-worker' => 'pwa#service_worker'
  # get 'manifest' => 'pwa#manifest'
end
# Updated routes
