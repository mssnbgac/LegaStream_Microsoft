#!/usr/bin/env ruby
require 'sqlite3'
require 'json'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

doc = db.execute('SELECT id, filename, status, analysis_results FROM documents WHERE id = 4').first

if doc
  puts "Document 4: #{doc['filename']}"
  puts "Status: #{doc['status']}"
  
  if doc['analysis_results']
    results = JSON.parse(doc['analysis_results'])
    puts "Entities extracted (in JSON): #{results['entities_extracted']}"
  end
  
  entities = db.execute('SELECT COUNT(*) as count FROM entities WHERE document_id = 4').first
  puts "Entities in database: #{entities['count']}"
else
  puts "Document 4 not found"
end

db.close
