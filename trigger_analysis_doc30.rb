#!/usr/bin/env ruby
require 'sqlite3'
require_relative 'app/services/ai_analysis_service'

puts "Triggering analysis for document 30..."

begin
  analyzer = AIAnalysisService.new(30)
  result = analyzer.analyze
  
  if result[:success]
    puts "✓ Analysis completed successfully!"
    puts "  Entities: #{result[:entities]&.length || 0}"
    puts "  Using real AI: #{result[:using_real_ai]}"
    puts "  Confidence: #{result[:confidence]}"
  else
    puts "✗ Analysis failed: #{result[:error]}"
  end
rescue => e
  puts "✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end
