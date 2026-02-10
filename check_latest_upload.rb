require 'sqlite3'
require 'time'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

puts "Last 3 documents uploaded:"
puts "=" * 80

docs = db.execute("SELECT id, original_filename, created_at, updated_at FROM documents ORDER BY id DESC LIMIT 3")

docs.each do |doc|
  puts "\nID: #{doc['id']}"
  puts "  File: #{doc['original_filename']}"
  puts "  Created: #{doc['created_at']}"
  puts "  Updated: #{doc['updated_at']}"
end

puts "\n" + "=" * 80
puts "Current time: #{Time.now}"
puts "\nIf you just uploaded THABIT RESUME.pdf, it should be ID 23 or higher."
puts "If you see a newer ID, then there's a new upload."

db.close
