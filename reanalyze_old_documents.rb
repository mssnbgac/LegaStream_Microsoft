#!/usr/bin/env ruby
require 'sqlite3'
require 'json'
require_relative 'app/services/ai_analysis_service'

puts "Re-analyzing Documents with Updated AI Service"
puts "=" * 70

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

# Find documents with the old "Acme Corporation" analysis
old_docs = db.execute(
  "SELECT * FROM documents WHERE analysis_results LIKE '%Acme Corporation%' AND status = 'completed' ORDER BY id DESC"
)

if old_docs.empty?
  puts "No documents found with old analysis results"
  db.close
  exit
end

puts "Found #{old_docs.length} documents with old analysis results\n\n"

old_docs.each do |doc|
  puts "Re-analyzing Document ID: #{doc['id']}"
  puts "  Filename: #{doc['original_filename']}"
  
  # Delete old entities
  db.execute("DELETE FROM entities WHERE document_id = ?", [doc['id']])
  db.execute("DELETE FROM compliance_issues WHERE document_id = ?", [doc['id']])
  
  # Set status to processing
  db.execute("UPDATE documents SET status = 'processing' WHERE id = ?", [doc['id']])
  
  # Run new analysis
  begin
    analyzer = AIAnalysisService.new(doc['id'])
    result = analyzer.analyze
    
    if result[:success]
      # Get updated results
      updated = db.execute("SELECT * FROM documents WHERE id = ?", [doc['id']]).first
      analysis = JSON.parse(updated['analysis_results'])
      
      puts "  ✅ Analysis complete:"
      puts "     - Entities: #{analysis['entities_extracted']}"
      puts "     - Compliance: #{(analysis['compliance_score'] * 100).round(1)}%"
      puts "     - Risk: #{analysis['risk_level']}"
      puts "     - Summary: #{analysis['summary'][0..80]}..."
    else
      puts "  ❌ Analysis failed: #{result[:error]}"
    end
  rescue => e
    puts "  ❌ Error: #{e.message}"
  end
  
  puts "\n" + "-" * 70 + "\n"
end

puts "\n✅ Re-analysis complete!"
puts "\nIMPORTANT: Restart your server to ensure it uses the updated code:"
puts "  1. Stop the server (Ctrl+C)"
puts "  2. Run: .\\start-production.ps1"

db.close
