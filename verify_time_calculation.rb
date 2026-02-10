require 'time'

# Most recent document from database
doc_updated = Time.parse("2026-02-08 09:40:16")
now = Time.now

puts "Current time: #{now}"
puts "Document updated: #{doc_updated}"
puts "=" * 80

diff_seconds = (now - doc_updated).to_i
diff_minutes = (diff_seconds / 60).floor
diff_hours = (diff_minutes / 60).floor

puts "\nTime difference:"
puts "  Seconds: #{diff_seconds}"
puts "  Minutes: #{diff_minutes}"
puts "  Hours: #{diff_hours}"

puts "\nWhat notification should show:"
if diff_minutes < 1
  puts "  'Just now'"
elsif diff_minutes < 60
  puts "  '#{diff_minutes} minute#{diff_minutes > 1 ? 's' : ''} ago'"
else
  puts "  '#{diff_hours} hour#{diff_hours > 1 ? 's' : ''} ago'"
end

puts "\n" + "=" * 80
puts "If you uploaded a document 20 minutes ago, it should be:"
twenty_min_ago = now - (20 * 60)
puts "  Created at: #{twenty_min_ago}"
puts "  But the most recent in DB is: #{doc_updated}"
puts "\nConclusion: The document you uploaded is NOT in the database yet!"
