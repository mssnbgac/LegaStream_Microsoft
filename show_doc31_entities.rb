#!/usr/bin/env ruby
require 'sqlite3'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

entities = db.execute("SELECT entity_type, COUNT(*) as count, AVG(confidence) as avg_conf FROM entities WHERE document_id = 31 GROUP BY entity_type ORDER BY entity_type")

puts "Entity Summary for Document 31:"
puts "=" * 60

entities.each do |e|
  puts "#{e['entity_type'].capitalize}: #{e['count']} entities (avg #{(e['avg_conf'] * 100).round}% confidence)"
end

puts "\n" + "=" * 60
puts "Sample entities:"
puts "=" * 60

samples = db.execute("SELECT * FROM entities WHERE document_id = 31 ORDER BY confidence DESC, entity_type LIMIT 10")
samples.each do |e|
  puts "#{e['entity_type'].upcase}: #{e['entity_value']} (#{(e['confidence'] * 100).round}%)"
end

db.close
