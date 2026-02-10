#!/usr/bin/env ruby
require 'sqlite3'
require 'json'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

puts "=== Checking Entity Count Mismatch ==="
puts

# Check all documents
docs = db.execute("SELECT id, filename, status, analysis_results FROM documents WHERE status = 'completed' ORDER BY id")

docs.each do |doc|
  puts "Document #{doc['id']}: #{doc['filename']}"
  
  if doc['analysis_results']
    results = JSON.parse(doc['analysis_results'])
    json_count = results['entities_extracted']
    
    db_count = db.execute("SELECT COUNT(*) as count FROM entities WHERE document_id = ?", [doc['id']]).first['count']
    
    match = json_count == db_count ? "✅" : "❌"
    puts "  #{match} JSON says: #{json_count} entities"
    puts "  #{match} Database has: #{db_count} entities"
    
    if json_count != db_count
      puts "  ⚠️  MISMATCH! Difference: #{json_count - db_count}"
      puts "  💡 Solution: Re-analyze this document (click Play button)"
    end
  else
    puts "  ⚠️  No analysis results"
  end
  
  puts
end

puts "=== Summary ==="
puts "Documents with mismatched counts need to be re-analyzed."
puts "This happens when documents were analyzed with old code."
puts "Just click the Play button (▶) to re-analyze them!"

db.close
