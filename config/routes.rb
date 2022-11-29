Rails.application.routes.draw do
  root "home#index"
  get "home" => "home#edit"
  post "events" => "events#create"
  get "events" => "events#index"
  get "logistic_regression" => "logistic_regression#index"
  devise_for :users
  resources :courses
  resources :activities
  # post 'events#create', to:'events#send_message'
end
