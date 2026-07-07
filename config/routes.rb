Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: "admin/dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    post "signup", to: "auth#signup"
    post "login", to: "auth#login"

    resources :users, only: [:index, :create, :update, :destroy]
    resources :leaves
  end
end