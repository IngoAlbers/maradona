Rails.application.routes.draw do
  mount ActionCable.server, at: '/cable'

  resources :users, only: [:show], param: :player_id do
    resource :nickname, only: [:edit, :update], module: :users
  end
  devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', registration: 'register', sign_up: 'cmon_let_me_in' }

  resources :squads, except: [:index], param: :parameterized_name do
    resources :member_invitations, only: [:new, :create], module: :squads
    resources :accept_invitations, only: [:create]      , module: :squads
    resources :reject_invitations, only: [:create]      , module: :squads
  end

  get 'global_ranking'      , to: 'ranking#index'     , as: :ranking
  get 'prediction_center'   , to: 'matches#index'     , as: :prediction_center
  get 'deactivate/:token'   , to: 'deactivations#new' , as: :deactivate
  get 'about'               , to: 'about#show'        , as: :about
  get 'join/:invitation_key', to: 'join_by_keys#new'  , as: :join_by_key

  namespace :admin do
    resource :sessions
    resources :matches do
      resources :final_scores, only: [:new, :create], module: :matches
    end
    get 'sign_in', to: 'sessions#new', as: :sign_in
    root to: 'matches#index'
  end

  authenticated :user do
    root 'users#show', as: :authenticated_root
  end

  root to: 'landing_page#show', as: :landing_page
end
