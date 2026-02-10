class ApplicationController < ActionController::API
  include ActionController::RequestForgeryProtection
  
  # Skip CSRF for API requests
  skip_before_action :verify_authenticity_token
  
  # Authentication and tenant context
  before_action :authenticate_user!
  before_action :set_tenant_context
  
  # Exception handling
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from StandardError, with: :internal_server_error

  def health
    render json: { 
      status: 'ok', 
      timestamp: Time.current,
      version: '2.0.0',
      services: {
        database: database_status,
        redis: redis_status
      }
    }
  end

  protected

  def authenticate_user!
    # Skip authentication for health check and auth endpoints
    return if controller_name == 'application' && action_name == 'health'
    return if controller_path.include?('auth')
    
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token
      begin
        decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')
        user_id = decoded_token[0]['user_id']
        @current_user = User.find(user_id)
        
        unless @current_user&.can_login?
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { error: 'No token provided' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def set_tenant_context
    if current_user
      TenantContext.current_tenant = current_user.tenant
    end
  end

  private

  def database_status
    ActiveRecord::Base.connection.execute('SELECT 1')
    'connected'
  rescue
    'disconnected'
  end

  def redis_status
    Redis.current.ping == 'PONG' ? 'connected' : 'disconnected'
  rescue
    'disconnected'
  end

  def not_found(exception)
    render json: { 
      error: 'Not Found', 
      message: exception.message 
    }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: { 
      error: 'Unprocessable Entity', 
      message: exception.message,
      details: exception.record&.errors&.full_messages
    }, status: :unprocessable_entity
  end

  def internal_server_error(exception)
    Rails.logger.error "Internal Server Error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render json: { 
      error: 'Internal Server Error',
      message: Rails.env.development? ? exception.message : 'Something went wrong'
    }, status: :internal_server_error
  end
end