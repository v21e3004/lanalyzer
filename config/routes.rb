Rails.application.routes.draw do
  root 'home#index'
  post "events"      => "events#create"
  get "events"      => "events#index"
  devise_for :users
  resources :courses
end
