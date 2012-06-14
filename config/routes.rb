Tafelmanager2::Application.routes.draw do

  resources :locations, :only => [:index, :show] 

  namespace :account do
    resource :session, :only => [:new, :create, :destroy]
    resources :response_sessions, :only => [:show]
    resource :password, :only => [:edit, :update]
    resource :password_reset, :only => [:new, :create] do
      get 'success'
    end
  end

  namespace :registration do 
    resource :organizers, :only => [:new, :create] 
    resource :participants, :only => [:new, :create]  do
      collection { get 'confirm' }
    end
    resource :conversation_leaders, :only => [:new, :create]  do
      collection { get 'confirm' }
    end
  end

  namespace :contributor do
    resource :profile, :only => [:edit, :update]
    resource :registration, :only => [:show]
  end

  namespace :city do 
    resources :projects 
    resources :locations do
      resource :publication, :on => :meber, :only => [:show, :new, :create, :edit, :update ]
    end
  end

  namespace :organizer do
    resources :locations, only: [:index, :new, :create, :show]
  end

  namespace :admin do 
    resources :tenants 
  end

  resources :conversations 


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

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
  root :to => 'account/sessions#new'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  #
end
