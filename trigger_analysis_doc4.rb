#!/usr/bin/env ruby
require 'sqlite3'
require_relative 'app/services/ai_analysis_service'

# Force immediate output
$stdout.sync = true

puts "=== Triggering Analysis for Document 4 ==="

# Reset document status
db = SQLite3::Database.new('storage/legastream.db')
db.execute("UPDATE documents SET status = 'processing' WHERE id = 4")
db.close

puts "Starting AI analysis..."
analyzer = AIAnalysisService.new(4)
result = analyzer.analyze

puts "\n=== Analysis Result ==="
puts "Success: #{result[:success]}"
puts "Entities found: #{result[:entities]&.length || 0}"
puts "Compliance score: #{result[:compliance]['score']}%"
puts "Risk level: #{result[:risks]['level']}"
puts "Confidence: #{result[:confidence]}%"

puts "\n=== Logs ==="
result[:logs].each do |log|
  puts "[#{log[:type].upcase}] #{log[:message]}"
end

if result[:entities] && result[:entities].length > 0
  puts "\n=== Sample Entities ==="
  result[:entities].first(5).each do |e|
    puts "  - #{e['type']}: #{e['value']}"
  end
end

# Check database
puts "\n=== Checking Database ==="
db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

entity_count = db.execute("SELECT COUNT(*) as count FROM entities WHERE document_id = 4").first['count']
puts "Entities in database: #{entity_count}"

issue_count = db.execute("SELECT COUNT(*) as count FROM compliance_issues WHERE document_id = 4").first['count']
puts "Compliance issues in database: #{issue_count}"

db.close
