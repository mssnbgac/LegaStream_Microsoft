#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

# Test if backend is responding
puts "Testing backend server..."

# 1. Test health check
uri = URI('http://localhost:3001/up')
response = Net::HTTP.get_response(uri)
puts "Health check: #{response.code} #{response.message}"

if response.code == '200'
  puts "✓ Backend is running"
else
  puts "✗ Backend is not responding"
  exit 1
end

# 2. Test login
puts "\nTesting login..."
uri = URI('http://localhost:3001/api/v1/auth/login')
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
request.body = { email: 'admin@legastream.com', password: 'password' }.to_json

response = http.request(request)
puts "Login: #{response.code} #{response.message}"

if response.code == '200'
  data = JSON.parse(response.body)
  token = data['token']
  puts "✓ Login successful, got token: #{token[0..20]}..."
  
  # 3. Test document upload
  puts "\nTesting document upload..."
  
  # Create a simple PDF
  pdf_content = "%PDF-1.4\n%Test PDF\n1 0 obj\n<<\n/Type /Catalog\n/Pages 2 0 R\n>>\nendobj\n2 0 obj\n<<\n/Type /Pages\n/Kids [3 0 R]\n/Count 1\n>>\nendobj\n3 0 obj\n<<\n/Type /Page\n/Parent 2 0 R\n/Resources <<\n/Font <<\n/F1 <<\n/Type /Font\n/Subtype /Type1\n/BaseFont /Times-Roman\n>>\n>>\n>>\n/MediaBox [0 0 612 792]\n/Contents 4 0 R\n>>\nendobj\n4 0 obj\n<<\n/Length 44\n>>\nstream\nBT\n/F1 12 Tf\n100 700 Td\n(Test Document) Tj\nET\nendstream\nendobj\nxref\n0 5\n0000000000 65535 f\n0000000015 00000 n\n0000000068 00000 n\n0000000125 00000 n\n0000000324 00000 n\ntrailer\n<<\n/Size 5\n/Root 1 0 R\n>>\nstartxref\n417\n%%EOF"
  
  boundary = "----WebKitFormBoundary#{rand(10**16)}"
  
  body = ""
  body << "--#{boundary}\r\n"
  body << "Content-Disposition: form-data; name=\"file\"; filename=\"test.pdf\"\r\n"
  body << "Content-Type: application/pdf\r\n"
  body << "\r\n"
  body << pdf_content
  body << "\r\n"
  body << "--#{boundary}--\r\n"
  
  uri = URI('http://localhost:3001/api/v1/documents')
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.path)
  request['Authorization'] = "Bearer #{token}"
  request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
  request.body = body
  
  response = http.request(request)
  puts "Upload: #{response.code} #{response.message}"
  puts "Response: #{response.body}"
  
  if response.code == '200' || response.code == '201'
    puts "✓ Upload successful!"
  else
    puts "✗ Upload failed!"
    puts "Error details: #{response.body}"
  end
else
  puts "✗ Login failed: #{response.body}"
end
