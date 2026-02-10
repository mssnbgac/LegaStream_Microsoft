#!/usr/bin/env ruby
require 'sqlite3'
require 'json'
require_relative 'app/services/ai_analysis_service'

# Force immediate output
$stdout.sync = true

puts "=== Auto-Fixing All Documents with Entity Mismatches ==="
puts

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

# Find documents with mismatches
docs = db.execute("SELECT id, filename, analysis_results FROM documents WHERE status = 'completed' ORDER BY id")

docs_to_fix = []

docs.each do |doc|
  if doc['analysis_results']
    results = JSON.parse(doc['analysis_results'])
    json_count = results['entities_extracted'] || 0
    
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

puts "\n=== Starting Automatic Re-Analysis ==="

success_count = 0
error_count = 0

docs_to_fix.each_with_index do |doc, index|
  puts "\n[#{index + 1}/#{docs_to_fix.length}] Analyzing Document #{doc[:id]}..."
  
  begin
    analyzer = AIAnalysisService.new(doc[:id])
    result = analyzer.analyze
    
    if result[:success]
      entity_count = result[:entities]&.length || 0
      puts "✅ Success! Extracted #{entity_count} entities"
      success_count += 1
    else
      puts "❌ Failed: #{result[:error]}"
      error_count += 1
    end
  rescue => e
    puts "❌ Error: #{e.message}"
    error_count += 1
  end
  
  # Small delay between documents
  sleep(0.5)
end

puts "\n=== Re-Analysis Complete ==="
puts "✅ Successfully fixed: #{success_count} documents"
puts "❌ Errors: #{error_count} documents" if error_count > 0
puts "\nAll documents are now in sync!"
puts "Refresh your browser to see the updated entity counts."
