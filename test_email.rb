#!/usr/bin/env ruby
require 'mail'
require 'dotenv/load'

puts "Testing Email Configuration..."
puts "=" * 50

# Load environment variables
smtp_host = ENV['SMTP_HOST']
smtp_port = ENV['SMTP_PORT']
smtp_user = ENV['SMTP_USERNAME']
smtp_pass = ENV['SMTP_PASSWORD']

puts "SMTP Host: #{smtp_host}"
puts "SMTP Port: #{smtp_port}"
puts "SMTP User: #{smtp_user}"
puts "SMTP Pass: #{smtp_pass ? smtp_pass.gsub(/./, '*') : 'NOT SET'}"
puts "=" * 50

# Configure Mail
Mail.defaults do
  delivery_method :smtp, {
    address: smtp_host,
    port: smtp_port.to_i,
    user_name: smtp_user,
    password: smtp_pass,
    authentication: 'plain',
    enable_starttls_auto: true,
    openssl_verify_mode: 'none'
  }
end

# Send test email
begin
  puts "\nSending test email..."
  
  mail = Mail.new do
    from     smtp_user
    to       smtp_user  # Send to yourself for testing
    subject  'LegaStream Email Test'
    body     "This is a test email from LegaStream.\n\nIf you receive this, your email configuration is working correctly!"
  end
  
  mail.deliver!
  
  puts "✅ Test email sent successfully!"
  puts "Check your inbox: #{smtp_user}"
  puts "\nIf you don't see it:"
  puts "1. Check your spam/junk folder"
  puts "2. Wait 30-60 seconds for delivery"
  puts "3. Verify the App Password is correct"
  
rescue => e
  puts "❌ Failed to send test email"
  puts "Error: #{e.class}"
  puts "Message: #{e.message}"
  puts "\nPossible issues:"
  puts "1. App Password might be incorrect"
  puts "2. 2-Factor Authentication not enabled on Gmail"
  puts "3. Network/firewall blocking SMTP"
  puts "4. Gmail security settings blocking the app"
end
