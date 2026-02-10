#!/usr/bin/env ruby
require 'sqlite3'
require 'json'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

doc = db.execute('SELECT * FROM documents WHERE id = 4').first

if doc
  puts "=== Document 4 Details ==="
  puts "ID: #{doc['id']}"
  puts "Filename: #{doc['filename']}"
  puts "Status: #{doc['status']}"
  puts "File type: #{doc['content_type']}"
  puts "\n=== Extracted Text ==="
  if doc['extracted_text'] && !doc['extracted_text'].empty?
    puts doc['extracted_text']
    puts "\n=== Text Length: #{doc['extracted_text'].length} characters ==="
  else
    puts "No extracted text stored in database"
    puts "Will use simulated extraction based on file type"
  end
  
  puts "\n=== Analysis Results ==="
  if doc['analysis_results']
    results = JSON.parse(doc['analysis_results'])
    puts JSON.pretty_generate(results)
  else
    puts "No analysis results yet"
  end
  
  puts "\n=== Entities in Database ==="
  entities = db.execute('SELECT * FROM entities WHERE document_id = 4')
  puts "Total: #{entities.length}"
  entities.each do |e|
    puts "  - #{e['entity_type']}: #{e['entity_value']} (confidence: #{e['confidence']})"
  end
  
  puts "\n=== Compliance Issues in Database ==="
  issues = db.execute('SELECT * FROM compliance_issues WHERE document_id = 4')
  puts "Total: #{issues.length}"
  issues.each do |i|
    puts "  - #{i['issue_type']} (#{i['severity']}): #{i['description']}"
  end
else
  puts "Document 4 not found"
end

db.close
