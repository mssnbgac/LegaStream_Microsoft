#!/usr/bin/env ruby
require 'sqlite3'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

puts "=== User Email Confirmation Status ==="
puts

users = db.execute("SELECT id, email, first_name, last_name, email_confirmed, created_at FROM users ORDER BY id")

confirmed = []
unconfirmed = []

users.each do |user|
  if user['email_confirmed'] == 1
    confirmed << user
  else
    unconfirmed << user
  end
end

puts "✅ CONFIRMED USERS (#{confirmed.length}):"
confirmed.each do |user|
  puts "  #{user['id']}. #{user['email']} (#{user['first_name']} #{user['last_name']})"
end

puts "\n❌ UNCONFIRMED USERS (#{unconfirmed.length}):"
if unconfirmed.empty?
  puts "  (none)"
else
  unconfirmed.each do |user|
    puts "  #{user['id']}. #{user['email']} (#{user['first_name']} #{user['last_name']})"
  end
  
  puts "\n💡 To confirm a user, run:"
  puts "   ruby confirm_user_email.rb <email>"
end

db.close
