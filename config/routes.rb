Rails.application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do

    post "signup", to: "auth#signup"
    post "login", to: "auth#login"

    post "users/send_bulk_notification",
         to: "users#send_bulk_notification"

    resources :users, only: [:index, :create, :update, :destroy]

    resources :hrs

    resources :leaves

    resources :device_tokens, only: [:create, :index]
    delete "device_tokens", to: "device_tokens#destroy"

    resources :notifications, only: [:index, :create, :destroy] do
      member do
        put :mark_as_read
      end

      collection do
        get :welcome
      end
    end

    post "save_fcm_token", to: "users#save_fcm_token"

    post "send_notification", to: "notifications#create"

  end

end