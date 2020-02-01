Rails.application.routes.draw do
  devise_for :users
  devise_scope :users do
    # I can't use "users" in original controller name because devise already used
    put 'user_conf/toggle_mode' => 'user_conf#toggle_mode', as: :toggle_mode
  end

  get 'accesses/hello'
  get 'accesses/goodbye'
  get 'dashboard/index'
  get 'sentences/search'
  resources :score_eng_not_writtens
  resources :score_eng_writtens
  resources :scores
  resources :sentences
  root 'accesses#hello'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
