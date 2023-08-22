# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  draw :turbo

  # Jumpstart views
  if Rails.env.development? || Rails.env.test?
    mount Jumpstart::Engine, at: "/jumpstart"
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # Administrate
  authenticated :user, lambda { |u| u.admin? } do
    namespace :admin do
      if defined?(Sidekiq)
        require "sidekiq/web"
        mount Sidekiq::Web => "/sidekiq"
      end

      resources :announcements
      resources :users do
        resource :impersonate, module: :user
      end
      resources :connected_accounts
      resources :accounts do
        member do
          get :organization_users, as: :organization_users
          get :invited_users, as: :invited_users
          patch :manage_access, as: :manage_access
        end
      end
      resources :account_users
      resources :plans
      namespace :pay do
        resources :customers
        resources :charges
        resources :payment_methods
        resources :subscriptions
      end

      resources :teams

      # StoryBuilding routes
      resources :questions
      resources :story_builders

      root to: "dashboard#show"
    end

    # Account invitations routes
    get "/admin/accounts/:id/invitations/new", to: "admin/account_invitations#new", as: :new_account_user_invitation
    post "/admin/accounts/:id/invitations", to: "admin/account_invitations#create", as: :create_account_user_invitation
    post "/admin/accounts/:id/invitations/bulk_import", to: "admin/account_invitations#bulk_import", as: :bulk_import_account_invitations
  end

  # API routes
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resource :auth
      resource :me, controller: :me
      resource :password
      resources :accounts
      resources :users
      resources :notification_tokens, only: :create
    end
  end

  # User account
  devise_for :users,
    controllers: {
      omniauth_callbacks: ("users/omniauth_callbacks" if defined? OmniAuth),
      registrations: "users/registrations",
      sessions: "users/sessions"
    }.compact
  devise_scope :user do
    get "session/otp", to: "sessions#otp"
  end

  resources :announcements, only: [:index, :show]
  resources :api_tokens
  resources :accounts do
    member do
      patch :switch
      get :organization_users, as: :organization_users
      get :invited_users, as: :invited_users
    end

    resource :transfer, module: :accounts
    resources :account_users, path: :members
    resources :account_invitations, path: :invitations, module: :accounts do
      member do
        post :resend
      end
    end
  end
  resources :account_invitations

  post "/accounts/:id/invitations/bulk_import", to: "accounts/account_invitations#bulk_import", as: :bulk_import_org_account_invitations

  resources :teams

  # Payments
  resource :billing_address
  namespace :payment_methods do
    resource :stripe, controller: :stripe, only: [:show]
  end
  resources :payment_methods
  namespace :subscriptions do
    resource :billing_address
    namespace :stripe do
      resource :trial, only: [:show]
    end
  end
  resources :subscriptions do
    resource :cancel, module: :subscriptions
    resource :pause, module: :subscriptions
    resource :resume, module: :subscriptions
    resource :upcoming, module: :subscriptions

    collection do
      patch :billing_settings
    end

    scope module: :subscriptions do
      resource :stripe, controller: :stripe, only: [:show]
    end
  end
  resources :charges do
    member do
      get :invoice
    end
  end

  resources :agreements, module: :users
  namespace :account do
    resource :password
  end
  resources :notifications, only: [:index, :show]
  namespace :users do
    resources :mentions, only: [:index]
  end
  namespace :user, module: :users do
    resource :two_factor, controller: :two_factor do
      get :backup_codes
      get :verify
    end
    resources :connected_accounts
  end

  namespace :action_text do
    resources :embeds, only: [:create], constraints: {id: /[^\/]+/} do
      collection do
        get :patterns
      end
    end
  end

  scope controller: :static do
    get :about
    get :terms
    get :privacy
    get :pricing
  end

  post :sudo, to: "users/sudo#create"

  match "/404", via: :all, to: "errors#not_found"
  match "/500", via: :all, to: "errors#internal_server_error"

  authenticated :user do
    root to: "dashboard#show", as: :user_root
    # Alternate route to use if logged in users should still see public root
    # get "/dashboard", to: "dashboard#show", as: :user_root
  end

  # Public marketing homepage
  root to: "static#index"
end
