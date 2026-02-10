#!/usr/bin/env ruby
require 'webrick'

# Test WEBrick header handling
server = WEBrick::HTTPServer.new(Port: 3002, AccessLog: [], Logger: WEBrick::Log.new(nil, WEBrick::Log::ERROR))

server.mount_proc '/' do |req, res|
  puts "=" * 60
  puts "Request received:"
  puts "Method: #{req.request_method}"
  puts "Path: #{req.path}"
  puts
  puts "Header access methods:"
  puts "  req['Content-Type']: #{req['Content-Type'].inspect}"
  puts "  req.content_type: #{req.content_type.inspect}"
  puts "  req.header['content-type']: #{req.header['content-type'].inspect}"
  puts
  puts "Body preview: #{req.body[0..100].inspect}"
  puts "=" * 60
  
  res.status = 200
  res.body = "OK"
end

puts "Test server starting on port 3002..."
puts "Send a multipart request to test header handling"

trap('INT') { server.shutdown }
server.start
