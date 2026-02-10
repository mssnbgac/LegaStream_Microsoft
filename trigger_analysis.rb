#!/usr/bin/env ruby
require 'net/http'
require 'json'

# Trigger analysis for document 4
uri = URI('http://localhost:3001/api/v1/documents/4/analyze')

request = Net::HTTP::Post.new(uri)
request['Authorization'] = 'Bearer legastream_token_3_1234567890'  # User 3 owns doc 4
request['Content-Type'] = 'application/json'

puts "Triggering AI analysis for document 4..."

response = Net::HTTP.start(uri.hostname, uri.port) do |http|
  http.request(request)
end

puts "Status: #{response.code}"
puts "Response: #{response.body}"

if response.code == '200'
  puts "\n✓ Analysis started! Waiting 15 seconds for it to complete..."
  sleep 15
  
  puts "\nChecking results..."
  system('ruby check_doc4.rb')
end
