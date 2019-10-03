Rails.application.routes.draw do
  resources :group_events do
    member do
      put 'publish'
    end
  end
end
