require 'net/http'
require 'json'
require 'uri'

# Test the notifications endpoint
uri = URI('http://localhost:3001/api/v1/documents')

# You'll need to add your auth token here
token = 'your_token_here'

request = Net::HTTP::Get.new(uri)
request['Authorization'] = "Bearer #{token}"
request['Content-Type'] = 'application/json'

begin
  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
  end
  
  puts "Status: #{response.code}"
  puts "=" * 80
  
  if response.code == '200'
    data = JSON.parse(response.body)
    docs = data['documents'] || []
    
    puts "Total documents: #{docs.length}"
    puts "\nMost recent 5 documents:"
    puts "=" * 80
    
    docs.sort_by { |d| d['updated_at'] }.reverse.take(5).each do |doc|
      updated = Time.parse(doc['updated_at'])
      now = Time.now
      minutes_ago = ((now - updated) / 60).round
      
      puts "\nID: #{doc['id']}"
      puts "  File: #{doc['original_filename']}"
      puts "  Status: #{doc['status']}"
      puts "  Updated: #{doc['updated_at']}"
      puts "  Time ago: #{minutes_ago} minutes"
      
      # Calculate what the notification would show
      if minutes_ago < 1
        time_display = "Just now"
      elsif minutes_ago < 60
        time_display = "#{minutes_ago} minute#{minutes_ago > 1 ? 's' : ''} ago"
      else
        hours = (minutes_ago / 60).floor
        time_display = "#{hours} hour#{hours > 1 ? 's' : ''} ago"
      end
      
      puts "  Notification shows: #{time_display}"
    end
  else
    puts "Error: #{response.body}"
  end
rescue => e
  puts "Error: #{e.message}"
  puts "\nNote: You need to be logged in to test this."
  puts "The browser has your auth token automatically."
end
