Rails.application.routes.draw do
  default_url_options host: ENV['WAGONS_URL']

  resources :phonograms

  root to: 'phonograms#index'

  namespace :api do
    namespace :v1 do
      resources :phonograms, only: %i[index show create]
    end
  end
end
