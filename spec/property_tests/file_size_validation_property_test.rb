#!/usr/bin/env ruby
# Property Test: File Size Validation
# Validates: US-1.1 - Upload PDF documents from any device
# Property 3: For any file upload, files under 50MB should be accepted and files over 50MB should be rejected

require 'json'
require 'net/http'
require 'uri'

class FileSizeValidationPropertyTest
  MAX_FILE_SIZE_MB = 50
  MAX_FILE_SIZE_BYTES = MAX_FILE_SIZE_MB * 1024 * 1024
  API_BASE_URL = 'http://localhost:3001'
  
  def initialize
    @passed = 0
    @failed = 0
    @errors = []
  end
  
  def run
    puts "=" * 80
    puts "PROPERTY TEST: File Size Validation"
    puts "=" * 80
    puts "Property: Files under 50MB accepted, files over 50MB rejected"
    puts "Validates: US-1.1"
    puts "-" * 80
    
    # Get auth token first
    @token = login_test_user
    unless @token
      puts "❌ Failed to authenticate test user"
      return false
    end
    
    # Test cases with different file sizes
    test_cases = [
      { size_mb: 0.1, should_accept: true, description: "Small file (100KB)" },
      { size_mb: 1, should_accept: true, description: "Medium file (1MB)" },
      { size_mb: 10, should_accept: true, description: "Large file (10MB)" },
      { size_mb: 49, should_accept: true, description: "Just under limit (49MB)" },
      { size_mb: 49.9, should_accept: true, description: "Very close to limit (49.9MB)" },
      { size_mb: 50, should_accept: true, description: "Exactly at limit (50MB)" },
      { size_mb: 50.1, should_accept: false, description: "Just over limit (50.1MB)" },
      { size_mb: 51, should_accept: false, description: "Over limit (51MB)" },
      { size_mb: 100, should_accept: false, description: "Way over limit (100MB)" },
    ]
    
    test_cases.each do |test_case|
      test_file_size(test_case[:size_mb], test_case[:should_accept], test_case[:description])
    end
    
    # Test edge case: empty file (0 bytes)
    test_empty_file
    
    print_results
    @failed == 0
  end
  
  private
  
  def login_test_user
    # Try to login with existing user or create one
    uri = URI("#{API_BASE_URL}/api/v1/auth/login")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    request.body = { email: 'test@example.com', password: 'password123' }.to_json
    
    response = http.request(request)
    
    if response.code == '200'
      data = JSON.parse(response.body)
      return data['token']
    else
      # Try to register
      uri = URI("#{API_BASE_URL}/api/v1/auth/register")
      request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      request.body = {
        user: {
          email: 'test@example.com',
          password: 'password123',
          first_name: 'Test',
          last_name: 'User'
        }
      }.to_json
      
      response = http.request(request)
      
      if response.code == '201'
        # Login again
        uri = URI("#{API_BASE_URL}/api/v1/auth/login")
        request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
        request.body = { email: 'test@example.com', password: 'password123' }.to_json
        response = http.request(request)
        
        if response.code == '200'
          data = JSON.parse(response.body)
          return data['token']
        end
      end
    end
    
    nil
  end
  
  def test_file_size(size_mb, should_accept, description)
    size_bytes = (size_mb * 1024 * 1024).to_i
    
    # Create a fake PDF file of the specified size
    pdf_header = "%PDF-1.4\n"
    pdf_content = pdf_header + ("A" * (size_bytes - pdf_header.length))
    
    # Create multipart form data
    boundary = "----WebKitFormBoundary#{SecureRandom.hex(16)}"
    body = create_multipart_body(pdf_content, "test_#{size_mb}mb.pdf", boundary)
    
    # Make upload request
    uri = URI("#{API_BASE_URL}/api/v1/documents")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path)
    request['Authorization'] = "Bearer #{@token}"
    request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
    request.body = body
    
    response = http.request(request)
    
    # Check if response matches expectation
    if should_accept
      if response.code == '200' || response.code == '201'
        @passed += 1
        puts "✓ #{description}: Correctly accepted (#{size_mb}MB)"
      else
        @failed += 1
        error_msg = "#{description}: Should accept but got #{response.code}"
        @errors << error_msg
        puts "✗ #{error_msg}"
        puts "  Response: #{response.body[0..200]}"
      end
    else
      if response.code == '422' || response.code == '413'
        data = JSON.parse(response.body) rescue {}
        if data['error']&.include?('size') || data['message']&.include?('size')
          @passed += 1
          puts "✓ #{description}: Correctly rejected (#{size_mb}MB)"
        else
          @failed += 1
          error_msg = "#{description}: Rejected but wrong error message"
          @errors << error_msg
          puts "✗ #{error_msg}"
          puts "  Expected size error, got: #{data['error'] || data['message']}"
        end
      else
        @failed += 1
        error_msg = "#{description}: Should reject but got #{response.code}"
        @errors << error_msg
        puts "✗ #{error_msg}"
        puts "  Response: #{response.body[0..200]}"
      end
    end
  end
  
  def test_empty_file
    # Create empty PDF
    pdf_content = ""
    boundary = "----WebKitFormBoundary#{SecureRandom.hex(16)}"
    body = create_multipart_body(pdf_content, "empty.pdf", boundary)
    
    uri = URI("#{API_BASE_URL}/api/v1/documents")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path)
    request['Authorization'] = "Bearer #{@token}"
    request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
    request.body = body
    
    response = http.request(request)
    
    if response.code == '422'
      data = JSON.parse(response.body) rescue {}
      if data['error']&.include?('empty') || data['message']&.include?('empty')
        @passed += 1
        puts "✓ Empty file: Correctly rejected"
      else
        @failed += 1
        puts "✗ Empty file: Rejected but wrong error message"
      end
    else
      @failed += 1
      puts "✗ Empty file: Should reject but got #{response.code}"
    end
  end
  
  def create_multipart_body(file_content, filename, boundary)
    body = ""
    body << "--#{boundary}\r\n"
    body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{filename}\"\r\n"
    body << "Content-Type: application/pdf\r\n"
    body << "\r\n"
    body << file_content
    body << "\r\n"
    body << "--#{boundary}--\r\n"
    body
  end
  
  def print_results
    puts "-" * 80
    puts "RESULTS:"
    puts "  Passed: #{@passed}"
    puts "  Failed: #{@failed}"
    puts "  Total:  #{@passed + @failed}"
    puts "-" * 80
    
    if @failed > 0
      puts "\nFAILURES:"
      @errors.each_with_index do |error, i|
        puts "  #{i + 1}. #{error}"
      end
    end
    
    if @failed == 0
      puts "\n✓ ALL PROPERTY TESTS PASSED"
      puts "Property validated: File size validation works correctly"
    else
      puts "\n✗ PROPERTY TESTS FAILED"
      puts "Property violated: File size validation has issues"
    end
    puts "=" * 80
  end
end

# Run the test if executed directly
if __FILE__ == $0
  require 'securerandom'
  
  test = FileSizeValidationPropertyTest.new
  success = test.run
  exit(success ? 0 : 1)
end
