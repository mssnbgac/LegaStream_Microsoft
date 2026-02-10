#!/usr/bin/env ruby
require 'sqlite3'
require_relative 'app/services/ai_analysis_service'

# Force immediate output
$stdout.sync = true

puts "=== Triggering Analysis for Document 1 ==="

# Reset document status
db = SQLite3::Database.new('storage/legastream.db')
db.execute("UPDATE documents SET status = 'processing' WHERE id = 1")
db.close

puts "Starting AI analysis..."
analyzer = AIAnalysisService.new(1)
result = analyzer.analyze

puts "\n=== Analysis Result ==="
puts "Success: #{result[:success]}"
puts "Entities found: #{result[:entities]&.length || 0}"

# Check database
puts "\n=== Checking Database ==="
db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

entity_count = db.execute("SELECT COUNT(*) as count FROM entities WHERE document_id = 1").first['count']
puts "Entities in database: #{entity_count}"

db.close
