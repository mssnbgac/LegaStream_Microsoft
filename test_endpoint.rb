#!/usr/bin/env ruby
require 'net/http'
require 'json'

uri = URI('http://localhost:3001/api/v1/documents/1/entities')

# Create request with auth header
request = Net::HTTP::Get.new(uri)
request['Authorization'] = 'Bearer legastream_token_1_1234567890'
request['Content-Type'] = 'application/json'

# Make request
response = Net::HTTP.start(uri.hostname, uri.port) do |http|
  http.request(request)
end

puts "Status: #{response.code}"
puts "Body: #{response.body}"
