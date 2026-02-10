#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

# Test GET /api/v1/documents endpoint

# 1. Login first
uri = URI('http://localhost:3001/api/v1/auth/login')
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
request.body = { email: 'admin@legastream.com', password: 'password' }.to_json

response = http.request(request)
puts "Login: #{response.code}"

if response.code == '200'
  data = JSON.parse(response.body)
  token = data['token']
  puts "Token: #{token[0..30]}..."
  
  # 2. Get documents
  puts "\nFetching documents..."
  uri = URI('http://localhost:3001/api/v1/documents')
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.path)
  request['Authorization'] = "Bearer #{token}"
  
  response = http.request(request)
  puts "GET /api/v1/documents: #{response.code}"
  
  if response.code == '200'
    data = JSON.parse(response.body)
    puts "Total documents: #{data['total']}"
    puts "Documents:"
    data['documents'].each do |doc|
      puts "  - ID: #{doc['id']}, Filename: #{doc['filename']}, Status: #{doc['status']}"
    end
  else
    puts "Error: #{response.body}"
  end
else
  puts "Login failed: #{response.body}"
end
