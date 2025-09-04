Rails.application.routes.draw do
  resources :kitetrips do
    resources :kitetrip_events
    resources :kitetrip_participants do
      collection do
        get :search_users
      end
      member do
        patch :update_role
      end
    end
    resources :kitetrip_routes
  end
  resources :companies, only: [ :index, :show, :edit, :update ]
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"
      delete "auth/logout", to: "auth#logout"  
      delete "auth/logout_all", to: "auth#logout_all"
      
      resource :user, only: [:show, :update]
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "kitetrips#index"
end
