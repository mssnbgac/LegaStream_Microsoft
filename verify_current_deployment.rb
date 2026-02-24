#!/usr/bin/env ruby
# Verify Current Deployment Status

require 'dotenv/load'
require_relative 'app/services/ai_provider'

puts "=" * 60
puts "DEPLOYMENT VERIFICATION"
puts "=" * 60
puts ""

# Check environment
puts "📋 Environment Check:"
puts "   AI_PROVIDER: #{ENV['AI_PROVIDER']}"
puts "   GEMINI_API_KEY: #{ENV['GEMINI_API_KEY'] ? '[SET]' : '[NOT SET]'}"
puts "   DEVELOPMENT_MODE: #{ENV['DEVELOPMENT_MODE']}"
puts ""

# Check AI Provider
puts "🤖 AI Provider Status:"
provider = AIProvider.new
puts "   Provider: #{provider.provider_name}"
puts "   Enabled: #{provider.enabled?}"
puts ""

# Test entity extraction
puts "🧪 Testing Entity Extraction:"
test_text = <<~TEXT
  EMPLOYMENT AGREEMENT
  
  This Employment Agreement ("Agreement") is entered into on March 1, 2026,
  between Acme Corporation, a company organized under the laws of New York,
  with offices at 123 Main Street, New York, NY 10001 ("Employer"),
  and John Smith, residing at 456 Oak Avenue, Brooklyn, NY 11201 ("Employee").
  
  1. POSITION AND DUTIES
  Employee shall serve as Senior Software Engineer and shall perform all duties
  assigned by the Employer diligently and professionally.
  
  2. COMPENSATION
  Employer shall pay Employee an annual salary of $75,000, payable in accordance
  with Employer's standard payroll practices.
  
  3. TERM
  This Agreement shall commence on March 1, 2026 and continue for a period of
  24 months, unless terminated earlier in accordance with Section 5.
  
  4. TERMINATION
  Either party may terminate this Agreement with 30 days written notice.
  
  5. LIQUIDATED DAMAGES
  In the event of breach, the breaching party shall pay liquidated damages of $5,000.
  
  6. GOVERNING LAW
  This Agreement shall be governed by the laws of the State of New York.
TEXT

puts "   Extracting entities from sample employment contract..."
puts ""

begin
  entities = provider.extract_entities(test_text)
  
  if entities.nil?
    puts "   ❌ ERROR: Provider returned nil"
  elsif entities.empty?
    puts "   ⚠️  WARNING: No entities extracted (empty array)"
  else
    puts "   ✅ SUCCESS: Extracted #{entities.length} entities"
    puts ""
    puts "   Entity Types Found:"
    
    # Group by type
    by_type = entities.group_by { |e| e['type'] }
    by_type.each do |type, items|
      puts "   - #{type}: #{items.length} items"
      items.first(3).each do |item|
        puts "     • #{item['value']} (#{(item['confidence'] * 100).round}%)"
      end
      puts "     ..." if items.length > 3
    end
  end
rescue => e
  puts "   ❌ ERROR: #{e.message}"
  puts "   #{e.class}"
  puts e.backtrace.first(3)
end

puts ""
puts "=" * 60
puts "VERIFICATION COMPLETE"
puts "=" * 60
