#!/usr/bin/env ruby
require 'sqlite3'
require 'json'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

doc = db.execute('SELECT * FROM documents WHERE id = 3').first

if doc
  puts "=== Document 3 Details ==="
  puts "ID: #{doc['id']}"
  puts "Filename: #{doc['filename']}"
  puts "Status: #{doc['status']}"
  puts "User ID: #{doc['user_id']}"
  
  if doc['analysis_results']
    results = JSON.parse(doc['analysis_results'])
    puts "\nEntities extracted (in JSON): #{results['entities_extracted']}"
  end
  
  entities = db.execute('SELECT COUNT(*) as count FROM entities WHERE document_id = 3').first
  puts "Entities in database: #{entities['count']}"
  
  if entities['count'] == 0
    puts "\n⚠️  Document 3 has no entities. User needs to click Play button to analyze it."
  else
    puts "\n✅ Document 3 has entities ready to view!"
  end
else
  puts "Document 3 not found"
end

db.close
