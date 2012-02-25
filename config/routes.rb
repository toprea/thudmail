Thudmail::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)


  match '/api/login/:username/:password' => 'api#login', :via => :get
  match '/api/message/:id' => 'api#info', :via => :get
  match '/api/message/:id/details' => 'api#details', :via => :get
  match '/api/message/:id/mark_read' => 'api#mark_read', :via => :post
  match '/api/message/:id/mark_unread' => 'api#mark_undread', :via => :post
  match '/api/message/:id/delete' => 'api#delete', :via => :delete
  match '/api/message/:id/attachment/:index' => 'api#attachment', :via => :get
  match '/api/labels' => 'api#labels'
  match '/api/label/:name' => 'api#label', :via => :get
  match '/api/search' => 'api#search', :via => :get
  

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
