#!/usr/bin/env ruby
# Test the full entity extraction flow

require 'dotenv/load'
require_relative 'app/services/ai_provider'

puts "=" * 60
puts "FULL EXTRACTION FLOW TEST"
puts "=" * 60
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

puts "1️⃣ Checking Environment"
puts "   AI_PROVIDER: #{ENV['AI_PROVIDER']}"
puts "   GEMINI_API_KEY: #{ENV['GEMINI_API_KEY'] ? '[SET]' : '[NOT SET]'}"
puts ""

puts "2️⃣ Initializing AIProvider"
provider = AIProvider.new
puts "   Provider: #{provider.provider_name}"
puts "   Enabled: #{provider.enabled?}"
puts ""

if !provider.enabled?
  puts "❌ ERROR: AI Provider is not enabled!"
  puts "   Check that GEMINI_API_KEY is set correctly"
  exit 1
end

puts "3️⃣ Calling extract_entities"
puts "   Text length: #{test_text.length} chars"
puts ""

begin
  result = provider.extract_entities(test_text)
  
  puts "4️⃣ Checking Result"
  puts "   Result class: #{result.class}"
  puts "   Result nil?: #{result.nil?}"
  
  if result.nil?
    puts "   ❌ ERROR: extract_entities returned nil"
    puts "   This means an exception was caught in AIProvider"
    puts "   Check the console output above for error messages"
  elsif result.is_a?(Array)
    puts "   Result is Array: #{result.length} items"
    
    if result.empty?
      puts "   ⚠️  WARNING: Array is empty"
      puts "   This means Gemini returned something but it couldn't be parsed"
    else
      puts "   ✅ SUCCESS: Got #{result.length} entities"
      puts ""
      puts "5️⃣ Entity Details:"
      result.first(10).each_with_index do |entity, i|
        puts "   #{i+1}. #{entity['type']}: #{entity['value']}"
        puts "      Context: #{entity['context']}"
        puts "      Confidence: #{(entity['confidence'] * 100).round}%"
        puts ""
      end
      
      # Check entity types
      types = result.map { |e| e['type'] }.uniq
      puts "6️⃣ Entity Types Found:"
      types.each do |type|
        count = result.count { |e| e['type'] == type }
        puts "   - #{type}: #{count} items"
      end
      puts ""
      
      # Check if using correct types
      expected_types = ['PARTY', 'ADDRESS', 'DATE', 'AMOUNT', 'OBLIGATION', 'CLAUSE', 'JURISDICTION', 'TERM', 'CONDITION', 'PENALTY']
      old_types = ['person', 'monetary', 'date', 'address']
      
      if types.any? { |t| expected_types.include?(t) }
        puts "✅ Using CORRECT entity types (UPPERCASE)"
      elsif types.any? { |t| old_types.include?(t) }
        puts "❌ Using OLD entity types (lowercase) - this shouldn't happen!"
      else
        puts "❓ Using UNKNOWN entity types: #{types.join(', ')}"
      end
    end
  else
    puts "   ❌ ERROR: Result is not an Array"
    puts "   Result: #{result.inspect}"
  end
  
rescue => e
  puts "❌ EXCEPTION CAUGHT:"
  puts "   Class: #{e.class}"
  puts "   Message: #{e.message}"
  puts "   Backtrace:"
  puts e.backtrace.first(10).map { |line| "     #{line}" }.join("\n")
end

puts ""
puts "=" * 60
puts "TEST COMPLETE"
puts "=" * 60
