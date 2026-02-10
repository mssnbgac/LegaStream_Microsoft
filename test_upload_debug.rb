#!/usr/bin/env ruby
# Debug script to test document upload

require 'net/http'
require 'json'
require 'uri'
require 'securerandom'

API_BASE_URL = 'http://localhost:3001'

# Login first
def login
  uri = URI("#{API_BASE_URL}/api/v1/auth/login")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
  request.body = { email: 'test@example.com', password: 'password123' }.to_json
  
  response = http.request(request)
  puts "Login response: #{response.code}"
  
  if response.code == '200'
    data = JSON.parse(response.body)
    puts "Login successful, got token"
    return data['token']
  else
    puts "Login failed: #{response.body}"
    return nil
  end
end

# Test upload
def test_upload(token)
  puts "\nTesting document upload..."
  
  # Create a small PDF
  pdf_content = "%PDF-1.4\n" + ("Test content " * 100)
  filename = "test_#{Time.now.to_i}.pdf"
  
  boundary = "----WebKitFormBoundary#{SecureRandom.hex(16)}"
  
  body = ""
  body << "--#{boundary}\r\n"
  body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{filename}\"\r\n"
  body << "Content-Type: application/pdf\r\n"
  body << "\r\n"
  body << pdf_content
  body << "\r\n"
  body << "--#{boundary}--\r\n"
  
  uri = URI("#{API_BASE_URL}/api/v1/documents")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.path)
  request['Authorization'] = "Bearer #{token}"
  request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
  request.body = body
  
  puts "Sending upload request..."
  response = http.request(request)
  
  puts "Upload response: #{response.code}"
  puts "Response body: #{response.body}"
  
  if response.code == '200' || response.code == '201'
    puts "\n✓ Upload successful!"
  else
    puts "\n✗ Upload failed!"
  end
end

# Run test
token = login
if token
  test_upload(token)
else
  puts "Cannot test upload without authentication"
end
