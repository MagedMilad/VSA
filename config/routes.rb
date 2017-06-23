Rails.application.routes.draw do
  get 'videos/index'

  get 'videos/new'

  get 'videos/create'

  get 'videos/show'

  get 'videos/home'


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
   root to: "videos#home"
  resources :videos
end
