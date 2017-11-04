Rails.application.routes.draw do

  root to: "members#index"

  get 'courses/open', to: "courses#open", as: "open_courses"
  resources :courses do |r|
    resources :tickets
  end

  get 'members/courses/:id', to: 'members#course', as: 'members_course'
  resources :members

  get 'settings', to: 'settings#index', as: 'settings'
  put 'settings', to: 'settings#update'

  get 'registrations', to: 'registrations#new', as: 'register'
  post 'registrations', to: 'registrations#create'
  delete 'registrations/:id', to: 'registrations#destroy', as: 'registration'
  post 'registration/:id/switch_role', to: 'registrations#switch_role', as: 'switch_role'

  post 'payments/webhook', to: 'payments#webhook'

  require 'sidekiq/web'

  mount Sidekiq::Web, at: "/sidekiq"
end
