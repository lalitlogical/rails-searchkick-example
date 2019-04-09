Rails.application.routes.draw do
  mount API::Base, at: '/'

  resources :mobile_phones, only: %i[index show] do
    collection do
      get :autocomplete
    end
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'mobile_phones#index'
end
