#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

puts "Testing Document Delete Functionality"
puts "=" * 70

# Configuration
BASE_URL = 'http://localhost:3001'

# First, login to get a token
puts "\n1. Logging in..."
uri = URI("#{BASE_URL}/api/v1/auth/login")
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Post.new(uri.path)
request['Content-Type'] = 'application/json'
request.body = {
  email: 'admin@legastream.com',
  password: 'password'
}.to_json

response = http.request(request)

if response.code.to_i != 200
  puts "❌ Login failed: #{response.code} - #{response.body}"
  exit 1
end

login_data = JSON.parse(response.body)
token = login_data['token']
puts "✅ Logged in successfully"

# Get list of documents
puts "\n2. Fetching documents..."
uri = URI("#{BASE_URL}/api/v1/documents")
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.path)
request['Authorization'] = "Bearer #{token}"
request['Content-Type'] = 'application/json'

response = http.request(request)

if response.code.to_i != 200
  puts "❌ Failed to fetch documents: #{response.code} - #{response.body}"
  exit 1
end

docs_data = JSON.parse(response.body)
documents = docs_data['documents']

if documents.empty?
  puts "❌ No documents found to test delete"
  exit 1
end

puts "✅ Found #{documents.length} documents"

# Pick the last document to delete
doc_to_delete = documents.last
puts "\n3. Attempting to delete document:"
puts "   ID: #{doc_to_delete['id']}"
puts "   Filename: #{doc_to_delete['original_filename']}"

# Try to delete
uri = URI("#{BASE_URL}/api/v1/documents/#{doc_to_delete['id']}")
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Delete.new(uri.path)
request['Authorization'] = "Bearer #{token}"
request['Content-Type'] = 'application/json'

puts "\n4. Sending DELETE request..."
puts "   URL: #{uri}"
puts "   Token: #{token[0..20]}..."

response = http.request(request)

puts "\n5. Response received:"
puts "   Status Code: #{response.code}"
puts "   Status Message: #{response.message}"
puts "   Body: #{response.body}"

if response.code.to_i == 200
  puts "\n✅ DELETE request successful!"
  
  # Verify document is gone
  puts "\n6. Verifying document was deleted..."
  uri = URI("#{BASE_URL}/api/v1/documents")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.path)
  request['Authorization'] = "Bearer #{token}"
  request['Content-Type'] = 'application/json'
  
  response = http.request(request)
  docs_data = JSON.parse(response.body)
  remaining_docs = docs_data['documents']
  
  if remaining_docs.any? { |d| d['id'] == doc_to_delete['id'] }
    puts "❌ Document still exists in database!"
  else
    puts "✅ Document successfully removed from database"
    puts "   Documents remaining: #{remaining_docs.length}"
  end
else
  puts "\n❌ DELETE request failed!"
  puts "\nPossible issues:"
  puts "  1. Server is not running the updated code (needs restart)"
  puts "  2. CORS issue (check server logs)"
  puts "  3. Authorization issue (token invalid)"
  puts "  4. Route not matching (check server routing)"
  
  puts "\nTo fix:"
  puts "  1. Stop the server (Ctrl+C)"
  puts "  2. Run: .\\start-production.ps1"
  puts "  3. Try deleting again from the UI"
end

puts "\n" + "=" * 70
