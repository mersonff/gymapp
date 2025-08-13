Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'pages#home'

  get 'home', to: "pages#home"
  get 'revenue_data', to: "pages#revenue_data"

  get 'signup', to: "users#new"
  get 'payments/:id/new', to: "payments#new"
  resources :users, except: [:new]
  resources :plans, except: [:show]
  resources :clients do
    resources :payments, except: [:edit, :update, :show, :destroy]
    resources :measurements, except: [:edit, :update, :show, :destroy]
    resources :skinfolds, except: [:edit, :update, :show, :destroy]
  end

  get 'login', to: "sessions#new"
  post 'login', to: "sessions#create"
  delete 'logout', to: "sessions#destroy"
end
