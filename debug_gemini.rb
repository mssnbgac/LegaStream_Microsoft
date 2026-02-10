#!/usr/bin/env ruby
require 'dotenv/load'
require_relative 'app/services/ai_provider'

provider = AIProvider.new
puts "Provider: #{provider.provider_name}"
puts "Enabled: #{provider.enabled?}"

text = "Test document with John Doe, email test@example.com, and date January 1, 2026. Amount: $1000."

puts "\nCalling extract_entities..."
result = provider.extract_entities(text)

puts "\nResult: #{result.inspect}"
puts "Result class: #{result.class}"
puts "Result length: #{result.length}" if result.is_a?(Array)
