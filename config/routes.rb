Rails.application.routes.draw do
  devise_for :users
  resources :achievements
  root to: 'welcome#index'
end
