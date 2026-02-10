#!/usr/bin/env ruby
require 'sqlite3'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

puts "=== Documents ==="
docs = db.execute("SELECT id, user_id, filename, status FROM documents")
docs.each do |doc|
  puts "ID: #{doc['id']}, User: #{doc['user_id']}, File: #{doc['filename']}, Status: #{doc['status']}"
end

puts "\n=== Entities for Document 1 ==="
entities = db.execute("SELECT * FROM entities WHERE document_id = 1")
puts "Found #{entities.length} entities"
entities.each do |e|
  puts "  - #{e['entity_type']}: #{e['entity_value']}"
end

db.close
