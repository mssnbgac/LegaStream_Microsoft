#!/usr/bin/env ruby
# Check the latest document and its entities

require 'sqlite3'
require 'json'
require 'time'

db = SQLite3::Database.new('storage/legastream.db')
db.results_as_hash = true

puts "=" * 60
puts "LATEST DOCUMENT CHECK"
puts "=" * 60
puts ""

# Get latest document
doc = db.execute("SELECT * FROM documents ORDER BY created_at DESC LIMIT 1").first

if doc
  puts "📄 Latest Document:"
  puts "   ID: #{doc['id']}"
  puts "   Filename: #{doc['filename']}"
  puts "   Status: #{doc['status']}"
  puts "   Created: #{doc['created_at']}"
  puts "   Updated: #{doc['updated_at']}"
  puts ""
  
  # Parse analysis results
  if doc['analysis_results']
    results = JSON.parse(doc['analysis_results'])
    puts "📊 Analysis Results:"
    puts "   Entities: #{results['entities_extracted']}"
    puts "   Compliance: #{results['compliance_score']}%"
    puts "   Confidence: #{results['confidence_score']}%"
    puts "   Risk: #{results['risk_level']}"
    puts "   Using Real AI: #{results['using_real_ai']}"
    puts ""
  end
  
  # Get entities
  entities = db.execute("SELECT * FROM entities WHERE document_id = ? ORDER BY id", [doc['id']])
  
  puts "🔍 Entities Found: #{entities.length}"
  puts ""
  
  if entities.any?
    # Group by type
    by_type = entities.group_by { |e| e['entity_type'] }
    
    by_type.each do |type, items|
      puts "#{type} (#{items.length})"
      items.first(5).each do |entity|
        conf = (entity['confidence'] * 100).round
        puts "  • #{entity['entity_value']} - #{conf}% confidence"
      end
      puts "  ..." if items.length > 5
      puts ""
    end
    
    # Check if using old types or new types
    old_types = ['person', 'monetary', 'date', 'address', 'email', 'phone']
    new_types = ['PARTY', 'AMOUNT', 'DATE', 'ADDRESS', 'OBLIGATION', 'CLAUSE', 'JURISDICTION', 'TERM', 'CONDITION', 'PENALTY']
    
    entity_types = by_type.keys
    
    puts "=" * 60
    if entity_types.any? { |t| old_types.include?(t) }
      puts "⚠️  WARNING: Using OLD entity types (fallback extraction)"
      puts "   This means Gemini API failed and system used regex fallback"
      puts ""
      puts "   Old types found: #{entity_types.select { |t| old_types.include?(t) }.join(', ')}"
      puts ""
      puts "   Expected types: #{new_types.join(', ')}"
    elsif entity_types.any? { |t| new_types.include?(t) }
      puts "✅ SUCCESS: Using NEW entity types (Gemini AI extraction)"
      puts "   Types found: #{entity_types.join(', ')}"
    else
      puts "❓ UNKNOWN: Entity types don't match expected patterns"
      puts "   Types found: #{entity_types.join(', ')}"
    end
    puts "=" * 60
  else
    puts "❌ No entities found for this document"
  end
else
  puts "❌ No documents found in database"
end

db.close
