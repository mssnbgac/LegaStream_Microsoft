#!/usr/bin/env ruby
require 'sqlite3'
require 'json'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

doc = db.execute("SELECT * FROM documents WHERE id = 29").first

puts "Document 29 Status Check"
puts "=" * 60
puts "ID: #{doc['id']}"
puts "Filename: #{doc['filename']}"
puts "Status: #{doc['status']}"
puts "Created: #{doc['created_at']}"
puts "Updated: #{doc['updated_at']}"
puts

if doc['analysis_results']
  results = JSON.parse(doc['analysis_results'])
  puts "Analysis Results:"
  puts "  Entities: #{results['entities_extracted']}"
  puts "  Compliance: #{results['compliance_score']}"
  puts "  Risk: #{results['risk_level']}"
end

# Check entities
entities = db.execute("SELECT COUNT(*) as count FROM entities WHERE document_id = 29").first
puts "\nEntities in database: #{entities['count']}"

db.close
