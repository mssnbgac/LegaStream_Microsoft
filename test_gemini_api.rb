#!/usr/bin/env ruby
# Direct test of Gemini API

require 'dotenv/load'
require 'net/http'
require 'json'
require 'uri'

api_key = ENV['GEMINI_API_KEY']

puts "=" * 60
puts "TESTING GEMINI API DIRECTLY"
puts "=" * 60
puts "\nAPI Key: #{api_key[0..10]}...#{api_key[-5..-1]}"

# Test text
text = <<~TEXT
  Vulnerability Assessment Report
  Date: January 16, 2026
  Prepared By: Muhammad Auwal Murtala
  Email: enginboy20@gmail.com
  
  This report details security vulnerabilities found in OWASP Juice Shop.
  The assessment identified broken access control issues.
TEXT

prompt = <<~PROMPT
  Extract entities from this legal document. Return ONLY a JSON array with this exact format:
  [{"type": "person", "value": "John Doe", "context": "Party to agreement"}, ...]
  
  Entity types: person, organization, date, monetary, location, clause, obligation
  
  Document text:
  #{text}
PROMPT

puts "\n📤 Sending request to Gemini..."

uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=#{api_key}")

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request.body = {
  contents: [{
    parts: [{ text: prompt }]
  }],
  generationConfig: {
    temperature: 0.2,
    maxOutputTokens: 1000
  }
}.to_json

puts "Request URL: #{uri.host}#{uri.path}"
puts "Request body size: #{request.body.length} bytes"

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end

puts "\n📥 Response received:"
puts "Status: #{response.code} #{response.message}"
puts "Body length: #{response.body.length} bytes"

data = JSON.parse(response.body)

puts "\n📋 Full Response:"
puts JSON.pretty_generate(data)

if data['candidates']
  text_response = data.dig('candidates', 0, 'content', 'parts', 0, 'text')
  puts "\n✅ Extracted text:"
  puts text_response
  
  # Try to parse JSON
  json_match = text_response.match(/\[.*\]/m)
  if json_match
    entities = JSON.parse(json_match[0])
    puts "\n🏷️  Parsed entities (#{entities.length}):"
    entities.each do |entity|
      puts "   - #{entity['type']}: #{entity['value']}"
    end
  else
    puts "\n⚠️  No JSON array found in response"
  end
elsif data['error']
  puts "\n❌ Error from Gemini:"
  puts "   #{data['error']['message']}"
end

puts "\n" + "=" * 60
