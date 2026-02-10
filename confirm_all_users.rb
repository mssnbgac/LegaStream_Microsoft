#!/usr/bin/env ruby
require 'sqlite3'

puts "=== Confirm All Unconfirmed Users ==="
puts

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

# Find all unconfirmed users
unconfirmed = db.execute("SELECT * FROM users WHERE email_confirmed = 0")

if unconfirmed.empty?
  puts "✅ All users are already confirmed!"
else
  puts "Found #{unconfirmed.length} unconfirmed users:"
  unconfirmed.each do |user|
    puts "  - #{user['email']} (#{user['first_name']} #{user['last_name']})"
  end
  
  puts "\nConfirming all users..."
  
  # Confirm all users
  db.execute("UPDATE users SET email_confirmed = 1, confirmation_token = NULL, updated_at = CURRENT_TIMESTAMP WHERE email_confirmed = 0")
  
  puts "✅ Successfully confirmed #{unconfirmed.length} users!"
  puts "\nAll users can now login without email confirmation."
end

db.close
