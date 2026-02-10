Rails.application.routes.draw do
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # ActionCable WebSocket endpoint
  mount ActionCable.server => '/cable'

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'auth/register', to: 'auth#register'
      post 'auth/login', to: 'auth#login'
      post 'auth/logout', to: 'auth#logout'
      get 'auth/me', to: 'auth#me'
      
      # Email confirmation
      get 'auth/confirm/:token', to: 'auth#confirm_email', as: :confirm_email
      post 'auth/resend_confirmation', to: 'auth#resend_confirmation'
      
      # Password reset
      post 'auth/forgot_password', to: 'auth#forgot_password'
      post 'auth/reset_password', to: 'auth#reset_password'

      # Documents
      resources :documents, only: [:index, :show, :create, :destroy] do
        member do
          post :analyze
          get :analysis_status
        end
      end

      # Dashboard stats
      get 'stats', to: 'dashboard#stats'
      
      # User profile
      get 'profile', to: 'users#profile'
      patch 'profile', to: 'users#update_profile'

      # Tenants (for multi-tenant management)
      resources :tenants, only: [:index, :show, :create, :update] do
        resources :users, only: [:index, :show, :create, :update, :destroy]
      end

      # Usage and billing
      resources :usage_records, only: [:index, :show]
      resources :billing_reports, only: [:index, :show]

      # Agent memory
      resources :agent_memories, only: [:index, :show, :create, :destroy]
    end
  end

  # Root route
  root "application#health"
end