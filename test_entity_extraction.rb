#!/usr/bin/env ruby
# Test entity extraction logic directly

text = <<~TEXT
LEGAL SERVICES AGREEMENT

This Agreement is entered into on January 15, 2024, between:

Client: Acme Corporation, represented by John Smith (CEO)
Address: 123 Main Street, New York, NY 10001

Service Provider: Beta Legal Services LLC, represented by Jane Doe (Managing Partner)
Address: 456 Park Avenue, New York, NY 10022

TERMS AND CONDITIONS:

1. SCOPE OF SERVICES
The Service Provider agrees to provide legal consultation services including contract review, compliance analysis, and regulatory guidance.

2. COMPENSATION
Total Fee: $50,000 USD
Payment Terms: Net 30 days

3. DATA PROTECTION
Both parties agree to comply with GDPR regulations for all personal data processing. Client data will be stored securely and processed only for agreed purposes.

4. CONFIDENTIALITY
All information exchanged shall remain confidential for a period of 5 years.

5. TERM AND TERMINATION
This agreement shall commence on February 1, 2024 and continue for 12 months unless terminated earlier.

6. GOVERNING LAW
This agreement shall be governed by the laws of the State of New York.

REFERENCES:
- GDPR Article 6(1)(a) - Consent
- New York Business Law § 899-aa
- Case precedent: Smith v. Jones, 123 F.3d 456 (2nd Cir. 2023)

SIGNATURES:

_______________________
John Smith, CEO
Acme Corporation
Date: January 15, 2024

_______________________
Jane Doe, Managing Partner
Beta Legal Services LLC
Date: January 15, 2024
TEXT

puts "=== Testing Entity Extraction Patterns ==="
puts "Text length: #{text.length} characters"
puts

# Helper to safely extract context
def safe_context(text, entity_text)
  return "" unless text && entity_text
  index = text.index(entity_text)
  return "" unless index
  
  start_pos = [index - 20, 0].max
  end_pos = [index + entity_text.length + 50, text.length].min
  "...#{text[start_pos...end_pos]}..."
rescue
  ""
end

entities = []

# Extract person names (simple pattern)
puts "=== Testing Person Names ==="
matches = text.scan(/([A-Z][a-z]+ [A-Z][a-z]+)/).flatten.uniq
puts "Found #{matches.length} matches: #{matches.inspect}"
matches.each do |name|
  entities << {
    'type' => 'person',
    'value' => name,
    'context' => safe_context(text, name),
    'confidence' => 0.85
  }
end

# Extract companies
puts "\n=== Testing Companies ==="
matches = text.scan(/([A-Z][a-z]+ (?:Corporation|Corp|LLC|Inc|Ltd))/).flatten.uniq
puts "Found #{matches.length} matches: #{matches.inspect}"
matches.each do |company|
  entities << {
    'type' => 'company',
    'value' => company,
    'context' => safe_context(text, company),
    'confidence' => 0.90
  }
end

# Extract dates
puts "\n=== Testing Dates ==="
matches = text.scan(/(\w+ \d{1,2}, \d{4})/).flatten.uniq
puts "Found #{matches.length} matches: #{matches.inspect}"
matches.each do |date|
  entities << {
    'type' => 'date',
    'value' => date,
    'context' => safe_context(text, date),
    'confidence' => 0.95
  }
end

# Extract amounts
puts "\n=== Testing Amounts ==="
matches = text.scan(/(\$[\d,]+(?:\.\d{2})?)/).flatten.uniq
puts "Found #{matches.length} matches: #{matches.inspect}"
matches.each do |amount|
  entities << {
    'type' => 'amount',
    'value' => amount,
    'context' => safe_context(text, amount),
    'confidence' => 0.95
  }
end

# Extract case citations
puts "\n=== Testing Case Citations ==="
matches = text.scan(/([A-Z][a-z]+ v\. [A-Z][a-z]+, \d+ F\.\d+d? \d+)/).flatten.uniq
puts "Found #{matches.length} matches: #{matches.inspect}"
matches.each do |citation|
  entities << {
    'type' => 'case_citation',
    'value' => citation,
    'context' => safe_context(text, citation),
    'confidence' => 0.92
  }
end

puts "\n=== Total Entities Extracted ==="
puts "Total: #{entities.length}"
entities.each do |e|
  puts "  - #{e['type']}: #{e['value']}"
end
