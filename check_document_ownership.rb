#!/usr/bin/env ruby
require 'sqlite3'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

puts "=== Document Ownership ==="
docs = db.execute("SELECT id, filename, user_id, status FROM documents ORDER BY id")
docs.each do |doc|
  user = db.execute("SELECT email FROM users WHERE id = ?", [doc['user_id']]).first
  puts "Doc #{doc['id']}: #{doc['filename']} (user_id: #{doc['user_id']}, email: #{user['email']}, status: #{doc['status']})"
end

puts "\n=== Users ==="
users = db.execute("SELECT id, email, first_name, last_name FROM users")
users.each do |user|
  puts "User #{user['id']}: #{user['email']} (#{user['first_name']} #{user['last_name']})"
end

db.close
