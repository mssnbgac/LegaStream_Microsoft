require 'sqlite3'
require 'time'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

puts "Monitoring for new document uploads..."
puts "Press Ctrl+C to stop"
puts "=" * 80

last_count = db.execute("SELECT COUNT(*) as count FROM documents").first['count']
puts "Current document count: #{last_count}"
puts "\nWaiting for new uploads..."

loop do
  sleep(2)
  
  current_count = db.execute("SELECT COUNT(*) as count FROM documents").first['count']
  
  if current_count > last_count
    puts "\n🎉 NEW DOCUMENT UPLOADED!"
    puts "=" * 80
    
    # Get the newest document
    doc = db.execute("SELECT * FROM documents ORDER BY id DESC LIMIT 1").first
    
    puts "ID: #{doc['id']}"
    puts "File: #{doc['original_filename']}"
    puts "Status: #{doc['status']}"
    puts "Created: #{doc['created_at']}"
    puts "User ID: #{doc['user_id']}"
    puts "=" * 80
    
    last_count = current_count
  end
end

db.close
