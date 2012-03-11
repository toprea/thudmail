Thudmail::Application.routes.draw do

  match '/api/login' => 'api#login', :via => :post
  match '/api/messages/:id' => 'api#message_info', :via => :get
  match '/api/messages/:id/details' => 'api#message_details', :via => :get
  match '/api/messages/:id/raw' => 'api#message_raw'
  match '/api/download_token' => 'api#download_token', :via => :get
  match '/api/messages/:id/attachments/:index' => 'api#attachment', :via => :get
  match '/api/labels' => 'api#labels'
  match '/api/labels/:name' => 'api#label', :via => :get
  match '/api/search' => 'api#search', :via => :get


  # See how all your routes lay out with "rake routes"
end
