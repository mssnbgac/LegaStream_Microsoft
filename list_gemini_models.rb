#!/usr/bin/env ruby
require 'dotenv/load'
require 'net/http'
require 'json'

api_key = ENV['GEMINI_API_KEY']
uri = URI("https://generativelanguage.googleapis.com/v1beta/models?key=#{api_key}")

response = Net::HTTP.get_response(uri)
data = JSON.parse(response.body)

puts "Available Gemini models that support generateContent:"
puts "=" * 60

data['models'].select { |m| m['supportedGenerationMethods'].include?('generateContent') }.each do |m|
  puts "- #{m['name']}"
end
