Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Rotas para sessões (login/logout)
  get 'login', to: 'sessions#new', as: 'login'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy', as: 'logout'

  # Rota para o dashboard
  get 'dashboard', to: 'dashboard#index', as: 'dashboard'

  # Rota para o extrato
  get 'extrato', to: 'extratos#show', as: 'extrato' 

  # Rotas para o depósito
  get 'deposito', to: 'depositos#new', as: 'novo_deposito'
  post 'deposito', to: 'depositos#create', as: 'criar_deposito'

  # Rotas para o saque
  get 'saque', to: 'saques#new', as: 'novo_saque'
  post 'saque', to: 'saques#create', as: 'realizar_saque'

  root to: redirect('/login')

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
