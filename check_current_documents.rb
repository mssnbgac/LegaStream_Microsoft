#!/usr/bin/env ruby
require 'sqlite3'
require 'json'

puts "Checking Current Documents in Database"
puts "=" * 70

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

# Get all documents
docs = db.execute("SELECT * FROM documents ORDER BY id DESC LIMIT 10")

if docs.empty?
  puts "No documents found in database"
  exit
end

puts "Found #{docs.length} recent documents:\n\n"

docs.each do |doc|
  puts "Document ID: #{doc['id']}"
  puts "  Filename: #{doc['original_filename']}"
  puts "  Status: #{doc['status']}"
  puts "  Created: #{doc['created_at']}"
  
  if doc['analysis_results']
    analysis = JSON.parse(doc['analysis_results'])
    puts "  Analysis Results:"
    puts "    - Entities: #{analysis['entities_extracted']}"
    puts "    - Compliance: #{(analysis['compliance_score'] * 100).round(1)}%"
    puts "    - Risk: #{analysis['risk_level']}"
    puts "    - Summary: #{analysis['summary'][0..80]}..."
  else
    puts "  Analysis Results: None"
  end
  
  # Check entities in database
  entities = db.execute("SELECT COUNT(*) as count FROM entities WHERE document_id = ?", [doc['id']]).first
  puts "  Entities in DB: #{entities['count']}"
  
  puts "\n" + "-" * 70 + "\n"
end

# Check if any documents have identical analysis results
puts "\nChecking for duplicate analysis results..."
analysis_hashes = {}
duplicates = []

docs.each do |doc|
  next unless doc['analysis_results']
  
  analysis = JSON.parse(doc['analysis_results'])
  key = "#{analysis['entities_extracted']}_#{analysis['compliance_score']}_#{analysis['risk_level']}"
  
  if analysis_hashes[key]
    duplicates << [analysis_hashes[key], doc['id']]
  else
    analysis_hashes[key] = doc['id']
  end
end

if duplicates.any?
  puts "⚠️  Found #{duplicates.length} pairs of documents with identical results:"
  duplicates.each do |pair|
    puts "  - Documents #{pair[0]} and #{pair[1]} have same analysis"
  end
else
  puts "✅ All documents have unique analysis results!"
end

db.close
