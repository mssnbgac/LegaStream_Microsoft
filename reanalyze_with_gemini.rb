#!/usr/bin/env ruby
# Re-analyze all documents with Gemini AI

require 'sqlite3'
require 'dotenv/load'
require_relative 'app/services/ai_analysis_service'

puts "=" * 70
puts "RE-ANALYZING ALL DOCUMENTS WITH GEMINI AI"
puts "=" * 70

# Get all documents
db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

docs = db.execute("SELECT * FROM documents ORDER BY id")

if docs.empty?
  puts "\n❌ No documents found in database"
  exit 0
end

puts "\n📊 Found #{docs.length} document(s) to re-analyze"
puts "\n" + "-" * 70

docs.each_with_index do |doc, index|
  puts "\n[#{index + 1}/#{docs.length}] Processing Document ID: #{doc['id']}"
  puts "   Filename: #{doc['filename']}"
  puts "   Current Status: #{doc['status']}"
  
  # Clear existing entities
  deleted = db.execute("DELETE FROM entities WHERE document_id = ?", [doc['id']])
  db.execute("DELETE FROM compliance_issues WHERE document_id = ?", [doc['id']])
  puts "   🧹 Cleared #{db.changes} existing entities"
  
  # Run AI analysis
  puts "   🤖 Running Gemini AI analysis..."
  
  begin
    service = AIAnalysisService.new(doc['id'])
    result = service.analyze
    
    if result[:success]
      puts "   ✅ Analysis complete!"
      puts "      - Using Real AI: #{result[:using_real_ai] ? 'YES' : 'NO (Fallback)'}"
      puts "      - Entities: #{result[:entities].length}"
      puts "      - Compliance: #{result[:compliance][:score]}%"
      puts "      - Confidence: #{result[:confidence]}%"
      
      if result[:summary] && result[:summary].length > 0
        summary_preview = result[:summary][0..80]
        summary_preview += "..." if result[:summary].length > 80
        puts "      - Summary: #{summary_preview}"
      end
    else
      puts "   ❌ Analysis failed: #{result[:error]}"
    end
  rescue => e
    puts "   ❌ Error: #{e.message}"
    puts "      #{e.backtrace.first}"
  end
  
  # Small delay to avoid rate limiting
  sleep(1) if index < docs.length - 1
end

db.close

puts "\n" + "=" * 70
puts "RE-ANALYSIS COMPLETE"
puts "=" * 70

# Show summary
db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

completed = db.execute("SELECT COUNT(*) as count FROM documents WHERE status = 'completed'").first['count']
total = db.execute("SELECT COUNT(*) as count FROM documents").first['count']
total_entities = db.execute("SELECT COUNT(*) as count FROM entities").first['count']

puts "\n📊 Final Statistics:"
puts "   - Documents Completed: #{completed}/#{total}"
puts "   - Total Entities Extracted: #{total_entities}"
puts "   - Average Entities per Document: #{total > 0 ? (total_entities.to_f / total).round(1) : 0}"

db.close

puts "\n✅ All documents have been re-analyzed with Gemini AI!"
puts "\n" + "=" * 70
