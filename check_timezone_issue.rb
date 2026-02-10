require 'time'

# Document upload time from database
doc_time_str = "2026-02-08 10:09:52"
doc_time = Time.parse(doc_time_str)

# Current server time
server_now = Time.now

puts "Document uploaded at: #{doc_time_str}"
puts "Parsed as: #{doc_time}"
puts "Current server time: #{server_now}"
puts "Server timezone: #{server_now.zone} (#{server_now.utc_offset / 3600} hours from UTC)"
puts "=" * 80

# Calculate difference
diff_seconds = (server_now - doc_time).to_i
diff_minutes = diff_seconds / 60

puts "\nTime difference:"
puts "  #{diff_seconds} seconds"
puts "  #{diff_minutes} minutes"
puts "  #{diff_minutes / 60} hours"

puts "\n" + "=" * 80
puts "What notification should show: "
if diff_minutes < 1
  puts "  'Just now'"
elsif diff_minutes < 60
  puts "  '#{diff_minutes} minutes ago'"
else
  hours = diff_minutes / 60
  puts "  '#{hours} hour#{hours > 1 ? 's' : ''} ago'"
end

puts "\n" + "=" * 80
puts "Your browser's local time (West African Time):"
puts "If your local time is different from server time,"
puts "the browser will calculate a different time difference."
puts "\nWhat is your current local time right now?"
