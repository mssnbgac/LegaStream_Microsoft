require 'sqlite3'
require 'json'
require 'time'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

puts "Recent Documents (Last 10):"
puts "=" * 80

docs = db.execute("SELECT id, original_filename, status, created_at, updated_at FROM documents ORDER BY updated_at DESC LIMIT 10")

docs.each do |doc|
  created = Time.parse(doc['created_at'])
  updated = Time.parse(doc['updated_at'])
  now = Time.now
  
  minutes_ago = ((now - updated) / 60).round
  
  puts "\nID: #{doc['id']}"
  puts "  File: #{doc['original_filename']}"
  puts "  Status: #{doc['status']}"
  puts "  Created: #{doc['created_at']}"
  puts "  Updated: #{doc['updated_at']}"
  puts "  Time ago: #{minutes_ago} minutes ago"
end

db.close
