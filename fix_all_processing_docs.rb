#!/usr/bin/env ruby
require 'sqlite3'
require_relative 'app/services/ai_analysis_service'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

# Get all processing documents
docs = db.execute("SELECT * FROM documents WHERE status = 'processing' ORDER BY id")

puts "Found #{docs.length} documents stuck in 'processing' status"
puts "=" * 80

docs.each do |doc|
  puts "\nProcessing Document ID: #{doc['id']} - #{doc['filename']}"
  
  begin
    analyzer = AIAnalysisService.new(doc['id'])
    result = analyzer.analyze
    
    if result[:success]
      puts "  ✓ Analysis completed!"
      puts "    - Entities: #{result[:entities]&.length || 0}"
      puts "    - Confidence: #{result[:confidence]}"
      puts "    - Using real AI: #{result[:using_real_ai]}"
    else
      puts "  ✗ Analysis failed: #{result[:error]}"
    end
  rescue => e
    puts "  ✗ Error: #{e.message}"
  end
end

db.close

puts "\n" + "=" * 80
puts "Done! Refresh your browser to see updated documents."
