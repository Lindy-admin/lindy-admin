Rails.application.routes.draw do

  resources :tenants
  root to: "members#index"
  get 'user_root', to: "users#index", as: "user_root"

  devise_for :user, skip: [:registrations]
  devise_scope :user do
     resources :users, path: "", only: [:new, :create], controller: "users" #-> url.com/users/new
  end
  resources :users

  get 'courses/open', to: "courses#open", as: "open_courses"
  resources :courses do |r|
    resources :tickets
  end

  get 'members/courses/:id', to: 'members#course', as: 'members_course'
  resources :members

  get 'settings', to: 'settings#index', as: 'settings'
  put 'settings', to: 'settings#update'

  get 'registrations/available', to: 'registrations#new', as: 'register'
  post 'registrations/:id/switch_role', to: 'registrations#switch_role', as: 'switch_role'
  post 'registrations/:id/set_status/:status', to: 'registrations#set_status', as: 'set_status'
  resources :registrations

  get 'payments/:id/status', to: 'payments#status', as: "payment_status"
  post 'payments/webhook', to: 'payments#webhook'

  require 'sidekiq/web'

  mount Sidekiq::Web, at: "/sidekiq"
end
