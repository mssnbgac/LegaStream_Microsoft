#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

# Test the entities endpoint
puts "=== Testing Entities Endpoint ==="

# First, login to get a token
puts "\n1. Logging in..."
uri = URI('http://localhost:3001/api/v1/auth/login')
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Post.new(uri.path)
request['Content-Type'] = 'application/json'
request.body = {
  email: 'admin@legastream.com',
  password: 'password'
}.to_json

response = http.request(request)
login_data = JSON.parse(response.body)

if login_data['token']
  puts "✅ Login successful"
  token = login_data['token']
else
  puts "❌ Login failed: #{login_data['error']}"
  exit 1
end

# Test entities endpoint for document 1 (owned by admin)
puts "\n2. Fetching entities for document 1..."
uri = URI('http://localhost:3001/api/v1/documents/1/entities')
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.path)
request['Authorization'] = "Bearer #{token}"

response = http.request(request)
puts "Status: #{response.code}"

if response.code == '200'
  data = JSON.parse(response.body)
  puts "✅ Entities endpoint working!"
  puts "\nResponse:"
  puts JSON.pretty_generate(data)
  
  puts "\n=== Entity Summary ==="
  puts "Total entities: #{data['total_entities']}"
  puts "Entities by type:"
  data['entities_by_type'].each do |type, count|
    puts "  - #{type}: #{count}"
  end
  
  puts "\n=== Sample Entities ==="
  data['entities'].first(5).each do |e|
    puts "  - #{e['entity_type']}: #{e['entity_value']} (#{(e['confidence'] * 100).round(1)}%)"
  end
else
  puts "❌ Request failed: #{response.code}"
  puts response.body
end
