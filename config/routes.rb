Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Point d'entrée : vérifie les droits (authenticate_user!) et redirige vers
  # le namespace correspondant au rôle de l'utilisateur (RootController).
  root to: "root#index"

  # Espaces dédiés par rôle. `after_sign_in_path_for` (voir RoleRedirectable)
  # redirige l'utilisateur vers le namespace correspondant à son rôle.
  namespace :admin do
    root to: "dashboard#index"
  end

  namespace :gestionnaire do
    root to: "dashboard#index"
  end

  namespace :formateur do
    root to: "dashboard#index"
  end

  namespace :stagiaire do
    root to: "dashboard#index"
  end

  namespace :opco do
    root to: "dashboard#index"
  end
end
