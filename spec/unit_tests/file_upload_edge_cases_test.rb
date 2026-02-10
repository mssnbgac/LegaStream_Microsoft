#!/usr/bin/env ruby
# Unit Test: File Upload Edge Cases
# Validates: US-1.1 - Upload PDF documents from any device

require 'json'
require 'net/http'
require 'uri'
require 'securerandom'

class FileUploadEdgeCasesTest
  API_BASE_URL = 'http://localhost:3001'
  
  def initialize
    @passed = 0
    @failed = 0
    @errors = []
  end
  
  def run
    puts "=" * 80
    puts "UNIT TEST: File Upload Edge Cases"
    puts "=" * 80
    
    @token = login_test_user
    unless @token
      puts "❌ Failed to authenticate"
      return false
    end
    
    test_empty_file
    test_corrupted_pdf
    test_non_pdf_file
    test_special_characters_in_filename
    test_path_traversal_attempt
    
    print_results
    @failed == 0
  end
  
  private
  
  def login_test_user
    uri = URI("#{API_BASE_URL}/api/v1/auth/login")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    request.body = { email: 'test@example.com', password: 'password123' }.to_json
    response = http.request(request)
    response.code == '200' ? JSON.parse(response.body)['token'] : nil
  end
  
  def test_empty_file
    puts "\nTest: Empty file"
    response = upload_file("", "empty.pdf")
    
    if response.code == '422'
      data = JSON.parse(response.body) rescue {}
      if data['error']&.downcase&.include?('empty')
        @passed += 1
        puts "  ✓ Empty file rejected"
      else
        @failed += 1
        puts "  ✗ Wrong error message"
      end
    else
      @failed += 1
      puts "  ✗ Should reject empty file"
    end
  end
  
  def test_corrupted_pdf
    puts "\nTest: Corrupted PDF"
    response = upload_file("NOT A PDF", "corrupted.pdf")
    
    if response.code == '422'
      @passed += 1
      puts "  ✓ Corrupted PDF rejected"
    else
      @failed += 1
      puts "  ✗ Should reject corrupted PDF"
    end
  end
  
  def test_non_pdf_file
    puts "\nTest: Non-PDF file"
    boundary = "----WebKitFormBoundary#{SecureRandom.hex(16)}"
    body = create_multipart_body("PNG IMAGE", "image.png", boundary, "image/png")
    response = upload_with_body(body, boundary)
    
    if response.code == '422'
      @passed += 1
      puts "  ✓ Non-PDF rejected"
    else
      @failed += 1
      puts "  ✗ Should reject non-PDF"
    end
  end
  
  def test_special_characters_in_filename
    puts "\nTest: Special characters in filename"
    pdf_content = "%PDF-1.4\n" + ("A" * 1000)
    response = upload_file(pdf_content, "test<>:\"|?*.pdf")
    
    if response.code == '200' || response.code == '201'
      data = JSON.parse(response.body) rescue {}
      if data['filename'] && !data['filename'].match?(/[<>:"|?*]/)
        @passed += 1
        puts "  ✓ Special chars sanitized"
      else
        @failed += 1
        puts "  ✗ Special chars not sanitized"
      end
    else
      @failed += 1
      puts "  ✗ Should accept after sanitization"
    end
  end
  
  def test_path_traversal_attempt
    puts "\nTest: Path traversal"
    pdf_content = "%PDF-1.4\n" + ("A" * 1000)
    response = upload_file(pdf_content, "../../etc/passwd.pdf")
    
    if response.code == '200' || response.code == '201'
      data = JSON.parse(response.body) rescue {}
      if data['filename'] && !data['filename'].include?('..')
        @passed += 1
        puts "  ✓ Path traversal blocked"
      else
        @failed += 1
        puts "  ✗ Path traversal not blocked"
      end
    else
      @failed += 1
      puts "  ✗ Should accept after sanitization"
    end
  end
  
  def upload_file(content, filename)
    boundary = "----WebKitFormBoundary#{SecureRandom.hex(16)}"
    body = create_multipart_body(content, filename, boundary)
    upload_with_body(body, boundary)
  end
  
  def upload_with_body(body, boundary)
    uri = URI("#{API_BASE_URL}/api/v1/documents")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path)
    request['Authorization'] = "Bearer #{@token}"
    request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
    request.body = body
    http.request(request)
  end
  
  def create_multipart_body(content, filename, boundary, content_type = "application/pdf")
    body = ""
    body << "--#{boundary}\r\n"
    body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{filename}\"\r\n"
    body << "Content-Type: #{content_type}\r\n"
    body << "\r\n"
    body << content
    body << "\r\n"
    body << "--#{boundary}--\r\n"
    body
  end
  
  def print_results
    puts "-" * 80
    puts "Passed: #{@passed}, Failed: #{@failed}"
    puts @failed == 0 ? "\n✓ ALL TESTS PASSED" : "\n✗ TESTS FAILED"
    puts "=" * 80
  end
end

if __FILE__ == $0
  test = FileUploadEdgeCasesTest.new
  success = test.run
  exit(success ? 0 : 1)
end
