#!/usr/bin/env ruby
require 'net/http'

pdf_content = "%PDF-1.4\nTest"
boundary = "----WebKitFormBoundaryTest123"

body = ""
body << "--#{boundary}\r\n"
body << "Content-Disposition: form-data; name=\"file\"; filename=\"test.pdf\"\r\n"
body << "Content-Type: application/pdf\r\n"
body << "\r\n"
body << pdf_content
body << "\r\n"
body << "--#{boundary}--\r\n"

uri = URI('http://localhost:3002/')
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Post.new(uri.path)
request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
request.body = body

puts "Sending multipart request..."
response = http.request(request)
puts "Response: #{response.code}"
