Rails.application.routes.draw do
  resources :phonograms

  root to: 'phonograms#index'
end
