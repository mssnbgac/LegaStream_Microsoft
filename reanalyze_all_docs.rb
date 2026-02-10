#!/usr/bin/env ruby
require 'sqlite3'
require_relative 'app/services/ai_analysis_service'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

# Get all completed documents
docs = db.execute("SELECT * FROM documents WHERE status = 'completed'")

puts "Re-analyzing #{docs.length} documents with improved entity extraction..."
puts "=" * 80

docs.each do |doc|
  puts "\nDocument #{doc['id']}: #{doc['filename']}"
  
  # Delete old entities and compliance issues
  db.execute("DELETE FROM entities WHERE document_id = ?", [doc['id']])
  db.execute("DELETE FROM compliance_issues WHERE document_id = ?", [doc['id']])
  db.execute("UPDATE documents SET status = 'processing' WHERE id = ?", [doc['id']])
  
  # Run analysis
  begin
    analyzer = AIAnalysisService.new(doc['id'])
    result = analyzer.analyze
    
    if result[:success]
      puts "  ✓ Completed - #{result[:entities]&.length || 0} entities"
      
      # Show confidence scores
      entities = db.execute("SELECT DISTINCT confidence FROM entities WHERE document_id = ? ORDER BY confidence DESC", [doc['id']])
      if entities.any?
        confidences = entities.map { |e| "#{(e['confidence'] * 100).round}%" }.uniq
        puts "  Confidence levels: #{confidences.join(', ')}"
      end
    else
      puts "  ✗ Failed: #{result[:error]}"
    end
  rescue => e
    puts "  ✗ Error: #{e.message}"
  end
end

db.close

puts "\n" + "=" * 80
puts "Done! Refresh your browser to see updated results."
