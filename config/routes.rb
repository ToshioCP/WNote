Rails.application.routes.draw do
  root 'static_pages#home'
# session -- logins controller
  post 'logins/create'
  get 'logins/new'
  delete 'logins/destroy'
# users controller
# notice: the path is singular form because user's id isn't nessesary in the path.
# The user is current_user who is known by session parameter.
  get 'user/backup', to: 'users#backup'
  get 'user/reset', to:'users#reset'
  get 'user/upload', to: 'users#upload'
  post 'user/restore', to:'users#restore'
#resources
  resource :user
  resources :images, except: :show
# Nested resources
#   Since the user is singular resource, it is not included in the nest. 
# (user - ) articles - sections - notes
# (user - ) images
  get 'articles/:id/epub', to: 'articles#epub'
  resources :articles do
    resources :sections, only: :new
  end
  resources :sections, except: [:index, :new] do
    resources :notes, only: :new
  end
  resources :notes, except: [:index, :new] do
  end
# admin
  get 'admin/list_users'
  delete 'admin/users/:id', to: 'admin#delete_user'
end
