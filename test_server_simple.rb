#!/usr/bin/env ruby
require 'webrick'
require 'json'

$stdout.sync = true

server = WEBrick::HTTPServer.new(Port: 3002)

server.mount_proc '/' do |req, res|
  path = req.path
  puts "Request: #{req.request_method} #{path}"
  
  res['Content-Type'] = 'application/json'
  res['Access-Control-Allow-Origin'] = '*'
  
  if path =~ %r{^/api/v1/documents/(\d+)/entities$}
    puts "  -> Matched entities route! Doc ID: #{$1}"
    res.body = {success: true, doc_id: $1}.to_json
  else
    puts "  -> No match, returning 404"
    res.status = 404
    res.body = {error: 'Not Found'}.to_json
  end
end

puts "Test server starting on port 3002..."
server.start
