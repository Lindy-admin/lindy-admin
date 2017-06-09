Rails.application.routes.draw do

  root to: "people#index"
  resources :courses
  resources :people
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'registrations', to: 'registrations#new', as: 'register'
  post 'registrations', to: 'registrations#create'
  delete 'registrations/:id', to: 'registrations#destroy', as: 'registration'
end
