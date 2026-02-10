#!/usr/bin/env ruby
require 'sqlite3'

puts "=== Manual Email Confirmation Tool ==="
puts

# Get email from command line or prompt
if ARGV[0]
  email = ARGV[0]
else
  print "Enter user email to confirm: "
  email = gets.chomp
end

email = email.downcase.strip

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

# Find user
user = db.execute("SELECT * FROM users WHERE email = ?", [email]).first

if user
  if user['email_confirmed'] == 1
    puts "✅ User #{email} is already confirmed!"
  else
    # Confirm the email
    db.execute(
      "UPDATE users SET email_confirmed = 1, confirmation_token = NULL, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
      [user['id']]
    )
    puts "✅ Successfully confirmed email for: #{email}"
    puts "   User can now login!"
  end
else
  puts "❌ User not found: #{email}"
  puts
  puts "Available users:"
  users = db.execute("SELECT email, email_confirmed FROM users")
  users.each do |u|
    status = u['email_confirmed'] == 1 ? "✅ Confirmed" : "❌ Not confirmed"
    puts "  - #{u['email']} (#{status})"
  end
end

db.close
