require 'sqlite3'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

# Count documents for user 10
count = db.execute("SELECT COUNT(*) as count FROM documents WHERE user_id = 10").first['count']
completed = db.execute("SELECT COUNT(*) as count FROM documents WHERE user_id = 10 AND status = 'completed'").first['count']

puts "User 10 Documents:"
puts "  Total: #{count}"
puts "  Completed: #{completed}"

# Show recent uploads
puts "\nRecent uploads:"
docs = db.execute("SELECT id, original_filename, status, created_at FROM documents WHERE user_id = 10 ORDER BY id DESC LIMIT 5")
docs.each do |doc|
  puts "  ID #{doc['id']}: #{doc['original_filename']} - #{doc['status']} - #{doc['created_at']}"
end

db.close
