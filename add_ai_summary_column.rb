#!/usr/bin/env ruby
require 'sqlite3'

puts "🔧 Adding ai_summary column to documents table..."

db = SQLite3::Database.new('storage/legastream.db')

begin
  db.execute("ALTER TABLE documents ADD COLUMN ai_summary TEXT")
  puts "✅ Column added successfully!"
rescue => e
  if e.message.include?('duplicate column')
    puts "⚠️  Column already exists"
  else
    puts "❌ Error: #{e.message}"
  end
end

# Verify
schema = db.execute("PRAGMA table_info(documents)")
has_ai_summary = schema.any? { |col| col[1] == 'ai_summary' }

puts "\n✅ Verification: ai_summary column exists: #{has_ai_summary}"

db.close
