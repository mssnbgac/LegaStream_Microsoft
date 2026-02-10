#!/usr/bin/env ruby
require 'sqlite3'
require 'json'
require_relative 'app/services/ai_analysis_service'

# Force immediate output
$stdout.sync = true

puts "=== Fixing All Documents with Entity Mismatches ==="
puts

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

# Find documents with mismatches
docs = db.execute("SELECT id, filename, analysis_results FROM documents WHERE status = 'completed' ORDER BY id")

docs_to_fix = []

docs.each do |doc|
  if doc['analysis_results']
    results = JSON.parse(doc['analysis_results'])
    json_count = results['entities_extracted']
    
    db_count = db.execute("SELECT COUNT(*) as count FROM entities WHERE document_id = ?", [doc['id']]).first['count']
    
    if json_count != db_count
      docs_to_fix << { id: doc['id'], filename: doc['filename'], json_count: json_count, db_count: db_count }
    end
  end
end

db.close

if docs_to_fix.empty?
  puts "✅ All documents are in sync! No fixes needed."
  exit 0
end

puts "Found #{docs_to_fix.length} documents that need fixing:"
docs_to_fix.each do |doc|
  puts "  - Document #{doc[:id]}: #{doc[:filename]} (JSON: #{doc[:json_count]}, DB: #{doc[:db_count]})"
end

puts "\nDo you want to re-analyze these documents? (y/n)"
response = gets.chomp.downcase

if response == 'y' || response == 'yes'
  puts "\n=== Starting Re-Analysis ==="
  
  docs_to_fix.each do |doc|
    puts "\n--- Analyzing Document #{doc[:id]}: #{doc[:filename]} ---"
    
    begin
      analyzer = AIAnalysisService.new(doc[:id])
      result = analyzer.analyze
      
      if result[:success]
        puts "✅ Success! Extracted #{result[:entities]&.length || 0} entities"
      else
        puts "❌ Failed: #{result[:error]}"
      end
    rescue => e
      puts "❌ Error: #{e.message}"
    end
    
    # Small delay between documents
    sleep(1)
  end
  
  puts "\n=== Re-Analysis Complete ==="
  puts "All documents have been re-analyzed with the fixed code!"
  puts "You can now view entities in the frontend."
else
  puts "\nSkipped. You can manually re-analyze by clicking the Play button in the UI."
end
