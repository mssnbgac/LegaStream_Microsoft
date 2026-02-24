#!/usr/bin/env ruby
# Test Gemini API directly to see what's being returned

require 'net/http'
require 'json'
require 'uri'
require 'dotenv/load'

api_key = ENV['GEMINI_API_KEY']

puts "Testing Gemini API..."
puts "API Key: #{api_key[0..10]}..." if api_key
puts ""

# Test text
test_text = <<~TEXT
  EMPLOYMENT AGREEMENT
  
  This Employment Agreement is entered into on March 1, 2026,
  between Acme Corporation with offices at 123 Main Street, New York,
  and John Smith.
  
  Employee shall perform duties diligently.
  Employer shall pay Employee an annual salary of $75,000.
  This Agreement shall continue for 24 months.
  Either party may terminate with 30 days notice.
  Liquidated damages of $5,000 apply for breach.
  Governed by the laws of New York.
TEXT

prompt = <<~PROMPT
  Extract legal entities from this document. Return ONLY JSON array.
  
  Use these 10 entity types:
  - PARTY: People or organizations (e.g., "Acme Corp", "John Smith")
  - ADDRESS: Physical addresses (e.g., "123 Main St, New York")
  - DATE: Dates (e.g., "March 1, 2026")
  - AMOUNT: Money (e.g., "$75,000")
  - OBLIGATION: Legal duties (e.g., "shall perform duties")
  - CLAUSE: Contract terms (e.g., "30 days notice")
  - JURISDICTION: Governing law (e.g., "New York law")
  - TERM: Duration (e.g., "24 months")
  - CONDITION: Requirements (e.g., "subject to approval")
  - PENALTY: Damages (e.g., "$5,000 penalty")
  
  Document:
  #{test_text}
  
  Return JSON array (no markdown):
  [{"type":"PARTY","value":"Acme Corp","context":"party to agreement","confidence":0.95}]
PROMPT

uri = URI("https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=#{api_key}")

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request.body = {
  contents: [{
    parts: [{ text: prompt }]
  }],
  generationConfig: {
    temperature: 0.2,
    maxOutputTokens: 2000
  }
}.to_json

puts "Sending request to Gemini..."
puts "URL: #{uri.to_s[0..80]}..."
puts ""

begin
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 60) do |http|
    http.request(request)
  end

  puts "Response Status: #{response.code}"
  puts ""
  
  if response.code == '200'
    data = JSON.parse(response.body)
    
    puts "Full Response:"
    puts JSON.pretty_generate(data)
    puts ""
    
    if data['candidates'] && data['candidates'][0]
      text = data.dig('candidates', 0, 'content', 'parts', 0, 'text')
      
      puts "Extracted Text:"
      puts text
      puts ""
      
      # Try to parse JSON from text
      cleaned = text.strip.sub(/^```json\s*/, '').sub(/```\s*$/, '')
      json_match = cleaned.match(/\[.*\]/m)
      
      if json_match
        puts "Found JSON array:"
        entities = JSON.parse(json_match[0])
        puts JSON.pretty_generate(entities)
        puts ""
        puts "Total entities: #{entities.length}"
      else
        puts "ERROR: No JSON array found in response"
        puts "Text starts with: #{text[0..100]}"
      end
    else
      puts "ERROR: No candidates in response"
    end
  else
    puts "ERROR: HTTP #{response.code}"
    puts response.body
  end
  
rescue => e
  puts "ERROR: #{e.class} - #{e.message}"
  puts e.backtrace.first(5)
end
