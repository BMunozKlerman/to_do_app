Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Serve built assets
  get "/builds/*path", to: "assets#show"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Resources
  resources :to_do_items, param: :token do
    member do
      patch :add_follower
      delete :remove_follower
      post :estimate_duration
    end
    resources :comments, only: [ :create, :destroy ], param: :token
  end

  resources :users, only: [ :index, :show ]

  # ActionCable routes
  mount ActionCable.server => "/cable"

  # Defines the root path route ("/")
  root "to_do_items#index"
end
