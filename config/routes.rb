Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'pages#home'

  get 'home', to: "pages#home"

  get 'signup', to: "users#new"
  get 'indebts', to: "indebts#index"
  get 'payments/:id/new', to: "payments#new"
  resources :users, except: [:new]
  resources :plans
  resources :clients do
    resources :payments, except: [:edit, :update, :show, :destroy, :index]
    resources :measurements, except: [:edit, :update, :show, :destroy, :index]
    resources :skinfolds, except: [:edit, :update, :show, :destroy, :index]
  end

  get 'login', to: "sessions#new"
  post 'login', to: "sessions#create"
  delete 'logout', to: "sessions#destroy"

end
