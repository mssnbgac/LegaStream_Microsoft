#!/usr/bin/env ruby
require 'webrick'
require 'json'

class TestServer
  def initialize(port = 3001)
    @port = port
    @server = WEBrick::HTTPServer.new(
      Port: @port,
      DocumentRoot: '.',
      AccessLog: [],
      Logger: WEBrick::Log.new(nil, WEBrick::Log::ERROR)
    )
    
    # In-memory user storage for demo
    @users = {
      'admin@legastream.com' => {
        id: 1,
        email: 'admin@legastream.com',
        password: 'password',
        first_name: 'Admin',
        last_name: 'User',
        full_name: 'Admin User',
        role: 'admin',
        created_at: Time.now.iso8601
      }
    }
    
    setup_routes
  end

  def setup_routes
    @server.mount_proc '/' do |req, res|
      # Set CORS headers
      res['Access-Control-Allow-Origin'] = '*'
      res['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
      res['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
      
      if req.request_method == 'OPTIONS'
        res.status = 200
        res.body = ''
        return
      end
      
      handle_request(req, res)
    end
  end

  def handle_request(req, res)
    path = req.path
    method = req.request_method
    
    puts "[#{Time.now}] #{method} #{path}"
    
    res['Content-Type'] = 'application/json'
    
    case path
    when '/api/v1/auth/register'
      handle_register(req, res)
    when '/api/v1/auth/login'
      handle_login(req, res)
    when '/api/v1/auth/forgot_password'
      handle_forgot_password(req, res)
    when '/api/v1/auth/change_password'
      handle_change_password(req, res)
    when '/api/v1/documents'
      handle_documents(req, res, method)
    when '/api/v1/stats'
      handle_stats(req, res)
    else
      puts "No route matched for #{path}"
      res.status = 404
      res.body = { error: 'Not Found' }.to_json
    end
  end

  def handle_register(req, res)
    puts "Handling register request"
    
    begin
      data = JSON.parse(req.body)
      user_data = data['user'] || {}
      
      email = user_data['email']&.downcase
      password = user_data['password']
      first_name = user_data['first_name']
      last_name = user_data['last_name']
      
      # Validate required fields
      if !email || !password || !first_name || !last_name
        res.status = 422
        res.body = { errors: ['All fields are required'] }.to_json
        return
      end
      
      # Check if user already exists
      if @users[email]
        res.status = 422
        res.body = { errors: ['Email already exists'] }.to_json
        return
      end
      
      # Create new user
      user_id = @users.length + 1
      @users[email] = {
        id: user_id,
        email: email,
        password: password, # In real app, this would be hashed
        first_name: first_name,
        last_name: last_name,
        full_name: "#{first_name} #{last_name}",
        role: 'user',
        created_at: Time.now.iso8601
      }
      
      puts "Created user: #{email}"
      
      res.status = 201
      res.body = {
        message: 'Registration successful! You can now log in with your credentials.',
        user: {
          id: user_id,
          email: email,
          first_name: first_name,
          last_name: last_name,
          full_name: "#{first_name} #{last_name}",
          role: 'user'
        }
      }.to_json
      
    rescue JSON::ParserError
      res.status = 400
      res.body = { errors: ['Invalid JSON data'] }.to_json
    rescue => e
      puts "Registration error: #{e.message}"
      res.status = 500
      res.body = { errors: ['Registration failed. Please try again.'] }.to_json
    end
  end

  def handle_login(req, res)
    puts "Handling login request"
    
    begin
      data = JSON.parse(req.body)
      email = data['email']&.downcase
      password = data['password']
      
      puts "Login attempt for: #{email}"
      
      # Find user
      user = @users[email]
      
      if user && user[:password] == password
        puts "Login successful for: #{email}"
        res.body = {
          token: "mock_jwt_token_#{user[:id]}_#{Time.now.to_i}",
          user: {
            id: user[:id],
            email: user[:email],
            first_name: user[:first_name],
            last_name: user[:last_name],
            full_name: user[:full_name],
            role: user[:role]
          },
          message: 'Login successful'
        }.to_json
      else
        puts "Login failed for: #{email}"
        res.status = 401
        res.body = { error: 'Invalid email or password' }.to_json
      end
      
    rescue JSON::ParserError
      res.status = 400
      res.body = { error: 'Invalid JSON data' }.to_json
    rescue => e
      puts "Login error: #{e.message}"
      res.status = 500
      res.body = { error: 'Login failed. Please try again.' }.to_json
    end
  end

  def handle_forgot_password(req, res)
    puts "Handling forgot password request"
    
    begin
      data = JSON.parse(req.body)
      email = data['email']&.downcase
      
      puts "Password reset requested for: #{email}"
      
      # Check if user exists (but don't reveal this for security)
      user = @users[email]
      
      if user
        puts "User found: #{email} - In production, email would be sent"
        # In production, this would generate a reset token and send email
        res.body = {
          message: 'Demo Mode: Password reset would be sent to your email. For demo purposes, you can use the default password "password" or create a new account.',
          demo_info: {
            note: 'This is a demo application. No actual emails are sent.',
            suggestion: 'Try logging in with password "password" or register a new account.'
          }
        }.to_json
      else
        puts "User not found: #{email}"
        # Don't reveal if email exists or not for security
        res.body = {
          message: 'Demo Mode: If an account with that email existed, password reset instructions would have been sent.',
          demo_info: {
            note: 'This is a demo application. No actual emails are sent.',
            suggestion: 'Try registering a new account or use admin@legastream.com with password "password".'
          }
        }.to_json
      end
      
    rescue JSON::ParserError
      res.status = 400
      res.body = { error: 'Invalid JSON data' }.to_json
    rescue => e
      puts "Forgot password error: #{e.message}"
      res.status = 500
      res.body = { error: 'Request failed. Please try again.' }.to_json
    end
  end

  def handle_change_password(req, res)
    puts "Handling change password request"
    
    begin
      data = JSON.parse(req.body)
      email = data['email']&.downcase
      current_password = data['current_password']
      new_password = data['new_password']
      
      # Find user
      user = @users[email]
      
      if user && user[:password] == current_password
        # Update password
        @users[email][:password] = new_password
        puts "Password updated for: #{email}"
        
        res.body = {
          message: 'Password updated successfully'
        }.to_json
      else
        res.status = 401
        res.body = { error: 'Current password is incorrect' }.to_json
      end
      
    rescue JSON::ParserError
      res.status = 400
      res.body = { error: 'Invalid JSON data' }.to_json
    rescue => e
      puts "Change password error: #{e.message}"
      res.status = 500
      res.body = { error: 'Password change failed. Please try again.' }.to_json
    end
  end

  def handle_documents(req, res, method)
    puts "Handling documents request"
    if method == 'GET'
      res.body = {
        documents: [],
        total: 0,
        processing: 0,
        completed: 0
      }.to_json
    elsif method == 'POST'
      res.body = {
        id: rand(1..100),
        filename: 'test_document.pdf',
        status: 'uploaded',
        message: 'Document uploaded successfully'
      }.to_json
    end
  end

  def handle_stats(req, res)
    puts "Handling stats request"
    res.body = {
      documents_processed: 0,
      processing_time_saved: '0h',
      ai_accuracy_rate: '98.7%',
      issues_flagged: 0,
      system_status: {
        ai_engine: 'operational',
        document_processing: 'idle',
        security_sandbox: 'secure',
        live_terminal: 'streaming'
      }
    }.to_json
  end

  def start
    puts "🚀 Test Server starting on port #{@port}"
    puts "🔧 Test endpoints: http://localhost:#{@port}/api/v1/*"
    
    trap('INT') { 
      puts "\n🛑 Shutting down server..."
      @server.shutdown 
    }
    
    @server.start
  end
end

if __FILE__ == $0
  server = TestServer.new(3001)
  server.start
end