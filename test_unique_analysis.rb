#!/usr/bin/env ruby
require 'sqlite3'
require 'json'
require_relative 'app/services/ai_analysis_service'

puts "Testing Unique Analysis Results for Different Documents"
puts "=" * 60

# Connect to database
db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

# Get user ID (use first user)
user = db.execute("SELECT id FROM users LIMIT 1").first
unless user
  puts "❌ No users found. Please create a user first."
  exit 1
end

user_id = user['id']
puts "Using user ID: #{user_id}"
puts

# Create 3 test documents
3.times do |i|
  db.execute(
    "INSERT INTO documents (user_id, filename, original_filename, file_size, content_type, status) VALUES (?, ?, ?, ?, ?, ?)",
    [user_id, "test_doc_#{i+1}.pdf", "Test Document #{i+1}.pdf", 50000 + (i * 10000), 'application/pdf', 'processing']
  )
  puts "✅ Created test document #{i+1} (ID: #{db.last_insert_row_id})"
end

puts
puts "Running AI Analysis on each document..."
puts "-" * 60

# Get the newly created documents
docs = db.execute("SELECT * FROM documents WHERE user_id = ? ORDER BY id DESC LIMIT 3", [user_id])

results = []

docs.each_with_index do |doc, index|
  puts "\n📄 Analyzing Document #{index + 1}: #{doc['original_filename']} (ID: #{doc['id']})"
  
  analyzer = AIAnalysisService.new(doc['id'])
  result = analyzer.analyze
  
  if result[:success]
    # Get updated document with analysis results
    updated_doc = db.execute("SELECT * FROM documents WHERE id = ?", [doc['id']]).first
    analysis = JSON.parse(updated_doc['analysis_results'])
    
    puts "   Entities Extracted: #{analysis['entities_extracted']}"
    puts "   Compliance Score: #{analysis['compliance_score'] * 100}%"
    puts "   Risk Level: #{analysis['risk_level']}"
    puts "   Summary: #{analysis['summary'][0..100]}..."
    
    results << {
      doc_id: doc['id'],
      entities: analysis['entities_extracted'],
      compliance: analysis['compliance_score'],
      risk: analysis['risk_level'],
      summary: analysis['summary']
    }
  else
    puts "   ❌ Analysis failed: #{result[:error]}"
  end
end

puts
puts "=" * 60
puts "COMPARISON OF RESULTS"
puts "=" * 60

# Check if results are different
if results.length == 3
  entities_unique = results.map { |r| r[:entities] }.uniq.length > 1
  compliance_unique = results.map { |r| r[:compliance] }.uniq.length > 1
  risk_unique = results.map { |r| r[:risk] }.uniq.length > 1
  summary_unique = results.map { |r| r[:summary] }.uniq.length > 1
  
  puts "Entities counts are unique: #{entities_unique ? '✅ YES' : '❌ NO (all same)'}"
  puts "Compliance scores are unique: #{compliance_unique ? '✅ YES' : '❌ NO (all same)'}"
  puts "Risk levels are unique: #{risk_unique ? '✅ YES' : '❌ NO (all same)'}"
  puts "Summaries are unique: #{summary_unique ? '✅ YES' : '❌ NO (all same)'}"
  
  puts
  if entities_unique && summary_unique
    puts "✅ SUCCESS: Documents are getting unique analysis results!"
  else
    puts "⚠️  WARNING: Some results are still identical across documents"
  end
else
  puts "❌ Could not compare - insufficient results"
end

puts
puts "Detailed Results:"
results.each_with_index do |r, i|
  puts "\nDocument #{i+1} (ID: #{r[:doc_id]}):"
  puts "  - Entities: #{r[:entities]}"
  puts "  - Compliance: #{(r[:compliance] * 100).round(1)}%"
  puts "  - Risk: #{r[:risk]}"
  puts "  - Summary: #{r[:summary][0..150]}..."
end

db.close
puts "\n✅ Test complete!"
