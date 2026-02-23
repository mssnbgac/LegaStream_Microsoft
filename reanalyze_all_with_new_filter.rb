#!/usr/bin/env ruby
require 'sqlite3'
require_relative 'app/services/ai_analysis_service'

puts "🔄 Re-analyzing ALL documents with new strict filter..."
puts "=" * 60

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

# Get all documents
documents = db.execute("SELECT id, filename, user_id FROM documents ORDER BY id DESC")

puts "Found #{documents.length} documents to re-analyze"
puts ""

documents.each_with_index do |doc, index|
  doc_id = doc['id']
  filename = doc['filename']
  
  puts "[#{index + 1}/#{documents.length}] Document ##{doc_id}: #{filename}"
  
  begin
    # Delete old entities for this document
    deleted = db.execute("DELETE FROM entities WHERE document_id = ?", [doc_id])
    puts "  ✓ Deleted old entities"
    
    # Delete old compliance issues
    db.execute("DELETE FROM compliance_issues WHERE document_id = ?", [doc_id])
    puts "  ✓ Deleted old compliance issues"
    
    # Reset document status to processing
    db.execute("UPDATE documents SET status = 'processing', analysis_results = NULL WHERE id = ?", [doc_id])
    puts "  ✓ Reset document status"
    
    # Re-analyze with new filter
    puts "  🤖 Starting AI analysis with new strict filter..."
    analyzer = AIAnalysisService.new(doc_id)
    result = analyzer.analyze
    
    if result[:success]
      entity_count = result[:entities].length
      party_count = result[:entities].count { |e| e[:type] == 'PARTY' || e['type'] == 'PARTY' }
      
      puts "  ✅ Analysis complete!"
      puts "     Total entities: #{entity_count}"
      puts "     PARTY entities: #{party_count}"
      puts "     Confidence: #{result[:confidence]}%"
    else
      puts "  ❌ Analysis failed: #{result[:error]}"
    end
    
  rescue => e
    puts "  ❌ Error: #{e.message}"
    puts "     #{e.backtrace.first}"
  end
  
  puts ""
  sleep(1) # Small delay between documents
end

db.close

puts "=" * 60
puts "✅ Re-analysis complete!"
puts ""
puts "🌐 Refresh your browser to see the updated results"
puts "   URL: https://legastream.onrender.com"
