Rails.application.routes.draw do
  get 'external_comments/create'
  get 'external_comments/destroy'
  resources :shops, only: [:index, :show] do
    resources :shop_comments, only: [:create, :destroy]
    resource :like, only: [:create, :destroy]
    member do
      post :analyze_ai
    end
  end
  # External likes for API-based shops
  resources :external_likes, only: [:create] do
    collection do
      delete :destroy
    end
  end
  
  # External comments for API-based shops
  resources :external_comments, only: [:create, :destroy]
  get 'shops/search', to: 'shops#search', as: :shops_search
  root to: 'shops#search'
  get 'homes/top'
  devise_for :users
  resources :users do
    collection do
      get :likes
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
