Rails.application.routes.draw do
  resources :score_eng_not_writtens
  resources :score_eng_writtens
  resources :scores
  resources :sentences
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
