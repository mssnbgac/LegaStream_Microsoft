#!/usr/bin/env ruby
# Test Gemini API Integration

require 'sqlite3'
require 'dotenv/load'
require_relative 'app/services/ai_analysis_service'

puts "=" * 60
puts "TESTING GEMINI AI INTEGRATION"
puts "=" * 60

# Find the most recent document
db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

doc = db.execute("SELECT * FROM documents ORDER BY id DESC LIMIT 1").first

if doc.nil?
  puts "\n❌ No documents found in database"
  puts "Please upload a document first"
  exit 1
end

puts "\n📄 Testing with document:"
puts "   ID: #{doc['id']}"
puts "   Filename: #{doc['filename']}"
puts "   Status: #{doc['status']}"

# Clear existing entities for this document
db.execute("DELETE FROM entities WHERE document_id = ?", [doc['id']])
puts "\n🧹 Cleared existing entities"

db.close

# Run AI analysis
puts "\n🤖 Starting AI analysis with Gemini..."
puts "-" * 60

service = AIAnalysisService.new(doc['id'])
result = service.analyze

puts "\n" + "=" * 60
puts "ANALYSIS RESULTS"
puts "=" * 60

if result[:success]
  puts "\n✅ Analysis completed successfully!"
  puts "\n📊 Statistics:"
  puts "   Using Real AI: #{result[:using_real_ai] ? 'YES (Gemini)' : 'NO (Fallback)'}"
  puts "   Entities Found: #{result[:entities].length}"
  puts "   Compliance Score: #{result[:compliance][:score]}%"
  puts "   Risk Level: #{result[:risks][:level]}"
  puts "   Confidence: #{result[:confidence]}%"
  
  puts "\n📝 Summary:"
  puts "   #{result[:summary]}"
  
  puts "\n🏷️  Entities (first 10):"
  result[:entities].first(10).each do |entity|
    confidence = entity['confidence'] || entity[:confidence] || 0.85
    puts "   - #{entity['type'] || entity[:type]}: #{entity['value'] || entity[:value]} (#{(confidence * 100).round}%)"
  end
  
  if result[:compliance][:issues].any?
    puts "\n⚠️  Compliance Issues:"
    result[:compliance][:issues].each do |issue|
      puts "   - #{issue}"
    end
  end
  
  puts "\n📋 Analysis Logs:"
  result[:logs].each do |log|
    puts "   [#{log[:level].upcase}] #{log[:message]}"
  end
else
  puts "\n❌ Analysis failed!"
  puts "   Error: #{result[:error]}"
  
  if result[:logs]
    puts "\n📋 Error Logs:"
    result[:logs].each do |log|
      puts "   [#{log[:level].upcase}] #{log[:message]}"
    end
  end
end

puts "\n" + "=" * 60
