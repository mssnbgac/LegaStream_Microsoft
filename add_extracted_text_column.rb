#!/usr/bin/env ruby
require 'sqlite3'

db = SQLite3::Database.new('storage/legastream.db')

# Check if column exists
columns = db.execute("PRAGMA table_info(documents)")
has_extracted_text = columns.any? { |col| col[1] == 'extracted_text' }

if has_extracted_text
  puts "✓ Column 'extracted_text' already exists"
else
  puts "Adding 'extracted_text' column to documents table..."
  db.execute("ALTER TABLE documents ADD COLUMN extracted_text TEXT")
  puts "✓ Column added successfully"
end

db.close
