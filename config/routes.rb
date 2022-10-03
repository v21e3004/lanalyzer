Rails.application.routes.draw do
  root "home#index"
  post "events" => "events#create"
  get "events" => "events#index"
  devise_for :users
  resources :courses
  resources :timetables
  # post 'events#create', to:'events#send_message'
end
