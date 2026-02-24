#!/usr/bin/env ruby
require 'sqlite3'
require 'json'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

# Get the latest document
doc = db.execute("SELECT * FROM documents ORDER BY id DESC LIMIT 1").first

if doc
  puts "Latest Document:"
  puts "  ID: #{doc['id']}"
  puts "  Filename: #{doc['filename']}"
  puts "  Status: #{doc['status']}"
  puts "  Created: #{doc['created_at']}"
  puts "  Updated: #{doc['updated_at']}"
  puts ""
  
  if doc['analysis_results']
    puts "Analysis Results:"
    results = JSON.parse(doc['analysis_results'])
    puts JSON.pretty_generate(results)
    puts ""
  else
    puts "No analysis results yet"
    puts ""
  end
  
  # Check entities
  entities = db.execute("SELECT * FROM entities WHERE document_id = ?", [doc['id']])
  puts "Entities in database: #{entities.length}"
  
  if entities.any?
    puts "\nEntity breakdown:"
    grouped = entities.group_by { |e| e['entity_type'] }
    grouped.each do |type, ents|
      puts "  #{type}: #{ents.length}"
      ents.first(3).each do |e|
        puts "    - #{e['entity_value']} (#{(e['confidence'] * 100).round}%)"
      end
    end
  else
    puts "  (No entities found in database)"
  end
  
  # Check extracted text
  if doc['extracted_text'] && !doc['extracted_text'].empty?
    puts "\nExtracted text length: #{doc['extracted_text'].length} chars"
    puts "Text preview:"
    puts doc['extracted_text'][0..300]
  else
    puts "\nNo extracted text"
  end
else
  puts "No documents found"
end

db.close
