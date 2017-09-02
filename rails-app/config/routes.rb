Rails.application.routes.draw do

  root to: "members#index"
  resources :courses do |r|
    resources :tickets
  end
  resources :members
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'registrations', to: 'registrations#new', as: 'register'
  post 'registrations', to: 'registrations#create'
  delete 'registrations/:id', to: 'registrations#destroy', as: 'registration'
  post 'registration/:id/switch_role', to: 'registrations#switch_role', as: 'switch_role'
end
