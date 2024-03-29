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
      resources :story_builders do
        member do
          patch :sort_questions
        end
      end

      resources :blogs do
        member do
          patch :publish
        end
      end

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
    resources :stories, module: :accounts
    resources :blogs, module: :accounts
    get :all_blogs, to: "accounts/blogs#all_blogs", as: :all_blogs
    resources :industries, module: :accounts
  end

  get "stories/:story_builder_id/questions", to: "accounts/stories#question_navigation", as: :question_navigation
  get "stories/:story_builder_id/question/:id/nodes", to: "accounts/stories#question_nodes", as: :question_nodes
  patch "stories/:id/update_visibility", to: "accounts/stories#update_visibility", as: :update_visibility
  patch "stories/:id/publish", to: "accounts/stories#publish", as: :publish_story
  get "stories/:id/final_version", to: "accounts/stories#final_version", as: :final_version
  get "question/:id/prompts", to: "accounts/stories#prompt_navigation", as: :prompt_navigation
  get "question/:id/nodes/:node_id/child_nodes", to: "accounts/stories#sub_nodes_per_node", as: :child_nodes_per_node
  post "question/:id/answers", to: "accounts/stories#track_answers", as: :track_answers
  get "/ai_content", to: "accounts/stories#ai_based_questions_content", as: :ai_content
  resources :account_invitations

  post "/accounts/:id/invitations/bulk_import", to: "accounts/account_invitations#bulk_import", as: :bulk_import_org_account_invitations

  resources :teams
  patch "/users/:id/update_team", to: "teams#update_user", as: :update_user

  resources :story_builders

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

  resources :registration_questions, module: :users, only: [:index]
  patch :update_registration_data, to: "users/registration_questions#update_data"

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
  get "storybuilder", to: "story_builders#storybuilder"
end
