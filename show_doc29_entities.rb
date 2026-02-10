#!/usr/bin/env ruby
require 'sqlite3'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

entities = db.execute("SELECT * FROM entities WHERE document_id = 29 ORDER BY entity_type, entity_value")

puts "Entities for Document 29:"
puts "=" * 80

entities.each do |e|
  puts "Type: #{e['entity_type']}"
  puts "Value: #{e['entity_value']}"
  puts "Context: #{e['context']}"
  puts "Confidence: #{(e['confidence'] * 100).round}%"
  puts "-" * 80
end

db.close
