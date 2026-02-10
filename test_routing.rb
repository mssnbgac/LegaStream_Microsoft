#!/usr/bin/env ruby

# Test the routing logic
path = "/api/v1/documents/1/entities"

puts "Testing path: #{path}"
puts

# Test regex matching
if path =~ %r{^/api/v1/documents/(\d+)/entities$}
  puts "✓ Regex matched!"
  puts "  Document ID: #{$1}"
else
  puts "✗ Regex did NOT match"
end

puts

# Test other patterns
patterns = [
  %r{^/api/v1/documents/(\d+)/entities$},
  %r{^/api/v1/documents/(\d+)/analyze$},
  %r{^/api/v1/documents/(\d+)$}
]

patterns.each_with_index do |pattern, i|
  if path =~ pattern
    puts "Pattern #{i+1} matched: #{pattern.inspect}"
    puts "  Captured: #{$1}"
  end
end
