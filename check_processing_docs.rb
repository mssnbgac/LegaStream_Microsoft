#!/usr/bin/env ruby
require 'sqlite3'
require 'json'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

# Get all processing documents
docs = db.execute("SELECT * FROM documents WHERE status = 'processing' ORDER BY created_at DESC")

puts "Documents stuck in 'processing' status:"
puts "=" * 80

docs.each do |doc|
  puts "\nDocument ID: #{doc['id']}"
  puts "Filename: #{doc['filename']}"
  puts "Created: #{doc['created_at']}"
  puts "Updated: #{doc['updated_at']}"
  puts "Status: #{doc['status']}"
  
  # Check if file exists
  file_path = File.join('storage', 'uploads', doc['filename'])
  puts "File exists: #{File.exist?(file_path)}"
  
  # Check for entities
  entities = db.execute("SELECT COUNT(*) as count FROM entities WHERE document_id = ?", [doc['id']]).first
  puts "Entities extracted: #{entities['count']}"
end

db.close
