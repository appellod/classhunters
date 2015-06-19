require 'resque/server'

Site::Application.routes.draw do
  get "errors/file_not_found"
  get "errors/unprocessable"
  get "errors/internal_server_error"
  root "site#home"
  mount Resque::Server.new, at: "/resque"
  match "/about", to: "site#about", via: "get"
  match "/contact", to: "site#contact", via: "get"
  match "/contact", to: "site#contact", via: "post"
  match "/terms", to: "site#terms", via: "get"
  match "/privacy", to: 'site#privacy', via: 'get'
  match "/signup", to: "users#new", via: "get"
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'get'
  match '/account', to: 'site#account', via: 'get'
  match '/account', to: 'site#edit_user', via: 'post'
  match '/stats', to: 'site#stats', via: 'get'
  match "/search", to: "search#index", via: "get"
  match "/location", to: "sessions#location", via: "post"
  match "/autocomplete", to: "site#autocomplete", via: "get"
  match "/reset-password", to: 'users#reset_password', via: "get", as: "reset_password"
  match "/reset-password", to: 'users#reset_password', via: "post"

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
  match "/schools/:id/sync", to: "schools#sync", via: :all, as: "school_sync"
  resources :schools do
    match "/courses/import", to: "courses#import", via: "get", as: "import_courses"
    match "/courses/import", to: "courses#import_action", via: "post"
    match "/courses/sessions", to: "course_sessions#index", via: "get", as: "sessions"
    match "/courses/edit", to: "courses#edit_index", via: "get", as: "edit_courses"
    match "/courses/sessions/edit", to: "course_sessions#edit_index", via: "get", as: "edit_sessions"
    match "/courses/sessions/:id/edit", to: "course_sessions#edit", via: "get", as: "edit_session"
    match "/courses/sessions/:id", to: "course_sessions#update", via: "patch", as: "session"
    match "/courses/sessions/:id", to: "course_sessions#destroy", via: "delete"
    match "/courses/sessions/new", to: "course_sessions#new", via: "get", as: "new_session"
    match "/courses/sessions", to: "course_sessions#create", via: "post"
    resources :courses
  end
  resources :courses, only: [:index]
  match "/courses/sessions", to: "course_sessions#index", via: "get", as: "course_sessions"
  match "/courses/json", to: "courses#json", via: "get", as: "course_json"
  match "/courses/search", to: "courses#get_results", via: "get"

  #Plugins
  match "/plugin-test", to: "site#plugin", via: "get"
  match "/plugin", to: "plugins#index", via: "get", as: "plugin"
  match "/plugin/sessions", to: "plugins#sessions", via: "get", as: "plugin_sessions"
  match "/plugin/:school_id", to: "plugins#index", via: "get", as: "plugin_school"
  match "/plugin/:school_id/sessions", to: "plugins#sessions", via: "get", as: "plugin_school_sessions"

  #APIs
  match '/apis/courses/select', to: 'apis#courses_select', via: 'get'
  match '/apis/courses/view/:id', to: 'apis#courses_view', via: 'get'
  match '/apis/courses/json', to: 'apis#courses_json', via: 'get'

  #Errors
  match '/404', to: 'errors#file_not_found', via: :all
  match '/422', to: 'errors#unprocessable', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all

  match '/test', to: 'site#test', via: :all

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
