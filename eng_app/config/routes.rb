Rails.application.routes.draw do
  devise_for :users
  get 'accesses/hello'
  get 'accesses/goodbye'
  get 'dashboard/index'
  resources :score_eng_not_writtens
  resources :score_eng_writtens
  resources :scores
  resources :sentences
  root 'accesses#hello'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
