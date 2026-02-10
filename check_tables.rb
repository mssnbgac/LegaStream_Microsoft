#!/usr/bin/env ruby
require 'sqlite3'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

puts "=== Tables in database ==="
tables = db.execute("SELECT name FROM sqlite_master WHERE type='table'")
tables.each do |table|
  puts "  - #{table['name']}"
end

puts "\n=== Entities table schema ==="
begin
  schema = db.execute("PRAGMA table_info(entities)")
  if schema.empty?
    puts "  Table does not exist!"
  else
    schema.each do |col|
      puts "  #{col['name']} (#{col['type']})"
    end
  end
rescue => e
  puts "  Error: #{e.message}"
end

puts "\n=== Check document 3 ==="
doc = db.execute("SELECT id, status, analysis_results FROM documents WHERE id = 3").first
if doc
  puts "  Status: #{doc['status']}"
  if doc['analysis_results']
    require 'json'
    results = JSON.parse(doc['analysis_results'])
    puts "  Entities extracted: #{results['entities_extracted']}"
  end
end

puts "\n=== Entities for document 3 ==="
entities = db.execute("SELECT COUNT(*) as count FROM entities WHERE document_id = 3").first
puts "  Count in entities table: #{entities['count']}"

db.close
