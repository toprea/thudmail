Thudmail::Application.routes.draw do

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


  # See how all your routes lay out with "rake routes"
end
