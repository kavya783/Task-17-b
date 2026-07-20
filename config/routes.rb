Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get "up" => "rails/health#show", as: :rails_health_check
 
 namespace :api do
  post "signup", to: "auth#signup"
  post "login", to: "auth#login"

  resources :users, only: [:index, :create, :update, :destroy]
  resources :leaves

  resources :device_tokens, only: [:create]

  get "device_tokens", to: "device_tokens#index"

  post "save_fcm_token", to: "users#save_fcm_token"

  post "send_notification", to: "notifications#create"
  
end
end