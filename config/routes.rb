require 'resque/server'

Site::Application.routes.draw do
  root "site#home"
  mount Resque::Server.new, at: "/resque"
  match "/about", to: "site#about", via: "get"
  match "/contact", to: "site#contact", via: "get"
  match "/contact", to: "site#contact", via: "post"
  match "/signup", to: "users#new", via: "get"
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'get'
  match '/dashboard', to: 'site#dashboard', via: 'get'
  match "/search", to: "search#index", via: "get"
  match "/location", to: "sessions#location", via: "post"
  match "/autocomplete", to: "site#autocomplete", via: "get"

  resources :users do
    match "/courses/add", to: "courses#add_to_user", via: "post", as: "add_course"
    match "/courses/remove", to: "courses#remove_from_user", via: "get", as: "remove_course"
    resources :courses, only: [:index]
    resources :schools, only: [:index]
  end
  resources :sessions, only: [:new, :create, :destroy]
  match "/schools/import", to: "schools#import", via: "get", as: "import_schools"
  match "/schools/import", to: "schools#import", via: "post", as: "import_schools_action"
  match "/schools/autocomplete", to: "schools#autocomplete", via: "get"
  resources :schools do
    match "/courses/import", to: "courses#import", via: "get", as: "import"
    match "/courses/import", to: "courses#import", via: "post", as: "import_action"
    resources :courses
  end
  resources :courses, only: [:index]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
