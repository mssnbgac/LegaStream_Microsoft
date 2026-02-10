#!/usr/bin/env ruby
require 'sqlite3'
require_relative 'app/services/ai_analysis_service'

puts "Re-analyzing document 29 with improved entity extraction..."

# Delete old entities
db = SQLite3::Database.new('storage/legastream.db')
db.execute("DELETE FROM entities WHERE document_id = 29")
db.execute("DELETE FROM compliance_issues WHERE document_id = 29")
db.execute("UPDATE documents SET status = 'processing' WHERE id = 29")
db.close

# Run analysis
begin
  analyzer = AIAnalysisService.new(29)
  result = analyzer.analyze
  
  if result[:success]
    puts "✓ Analysis completed!"
    puts "  Entities: #{result[:entities]&.length || 0}"
    puts "  Confidence: #{result[:confidence]}"
    puts "  Using real AI: #{result[:using_real_ai]}"
    
    # Show entity breakdown
    db = SQLite3::Database.new('storage/legastream.db')
    db.results_as_hash = true
    entities = db.execute("SELECT entity_type, COUNT(*) as count FROM entities WHERE document_id = 29 GROUP BY entity_type")
    puts "\n  Entity breakdown:"
    entities.each do |e|
      puts "    - #{e['entity_type']}: #{e['count']}"
    end
    db.close
  else
    puts "✗ Analysis failed: #{result[:error]}"
  end
rescue => e
  puts "✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end
