#!/usr/bin/env ruby
# AI Provider Setup Script

puts "=" * 70
puts "LegaStream AI Provider Setup"
puts "=" * 70
puts

puts "Choose your AI provider:"
puts "1. Google Gemini (Recommended - Free tier available)"
puts "2. Anthropic Claude (Most accurate)"
puts "3. OpenAI GPT (Most popular)"
puts "4. Ollama (Local - Free but slower)"
puts "5. Skip (use fallback mode - not recommended for production)"
puts

print "Enter choice (1-5): "
choice = gets.chomp

provider = case choice
when '1' then 'gemini'
when '2' then 'claude'
when '3' then 'openai'
when '4' then 'ollama'
else nil
end

if provider.nil?
  puts "\nSkipping AI setup. System will use fallback mode."
  puts "⚠️  WARNING: Fallback mode is NOT suitable for production!"
  exit
end

puts "\n" + "=" * 70
puts "Setting up #{provider.upcase}"
puts "=" * 70

# Read current .env
env_content = File.exist?('.env') ? File.read('.env') : ''

# Update or add AI_PROVIDER
if env_content.include?('AI_PROVIDER=')
  env_content.gsub!(/AI_PROVIDER=.*/, "AI_PROVIDER=#{provider}")
else
  env_content += "\n# AI Provider Configuration\nAI_PROVIDER=#{provider}\n"
end

case provider
when 'gemini'
  puts "\n📝 Get your free Gemini API key:"
  puts "   1. Go to: https://makersuite.google.com/app/apikey"
  puts "   2. Click 'Create API Key'"
  puts "   3. Copy the key"
  puts
  print "Paste your Gemini API key (or press Enter to skip): "
  api_key = gets.chomp
  
  if api_key.empty?
    puts "\n⚠️  No API key provided. Add it to .env later:"
    puts "   GEMINI_API_KEY=your-key-here"
  else
    if env_content.include?('GEMINI_API_KEY=')
      env_content.gsub!(/GEMINI_API_KEY=.*/, "GEMINI_API_KEY=#{api_key}")
    else
      env_content += "GEMINI_API_KEY=#{api_key}\n"
    end
    puts "\n✅ Gemini API key configured!"
  end

when 'claude'
  puts "\n📝 Get your Claude API key:"
  puts "   1. Go to: https://console.anthropic.com/"
  puts "   2. Create account and get API key"
  puts
  print "Paste your Claude API key (or press Enter to skip): "
  api_key = gets.chomp
  
  if api_key.empty?
    puts "\n⚠️  No API key provided. Add it to .env later:"
    puts "   ANTHROPIC_API_KEY=your-key-here"
  else
    if env_content.include?('ANTHROPIC_API_KEY=')
      env_content.gsub!(/ANTHROPIC_API_KEY=.*/, "ANTHROPIC_API_KEY=#{api_key}")
    else
      env_content += "ANTHROPIC_API_KEY=#{api_key}\n"
    end
    puts "\n✅ Claude API key configured!"
  end

when 'openai'
  puts "\n📝 Get your OpenAI API key:"
  puts "   1. Go to: https://platform.openai.com/api-keys"
  puts "   2. Create API key"
  puts
  print "Paste your OpenAI API key (or press Enter to skip): "
  api_key = gets.chomp
  
  if api_key.empty?
    puts "\n⚠️  No API key provided. Add it to .env later:"
    puts "   OPENAI_API_KEY=your-key-here"
  else
    if env_content.include?('OPENAI_API_KEY=')
      env_content.gsub!(/OPENAI_API_KEY=.*/, "OPENAI_API_KEY=#{api_key}")
    else
      env_content += "OPENAI_API_KEY=#{api_key}\n"
    end
    puts "\n✅ OpenAI API key configured!"
  end

when 'ollama'
  puts "\n📝 Ollama Setup:"
  puts "   1. Install Ollama: https://ollama.ai/"
  puts "   2. Run: ollama pull llama2"
  puts "   3. Start Ollama service"
  puts
  puts "✅ Ollama configured (no API key needed)"
  
  unless env_content.include?('OLLAMA_HOST=')
    env_content += "OLLAMA_HOST=http://localhost:11434\n"
    env_content += "OLLAMA_MODEL=llama2\n"
  end
end

# Write updated .env
File.write('.env', env_content)

puts "\n" + "=" * 70
puts "✅ Setup Complete!"
puts "=" * 70
puts "\nNext steps:"
puts "1. Restart the server: ruby production_server.rb"
puts "2. Upload a document to test real AI analysis"
puts "3. Check AI_PROVIDER_SETUP.md for more details"
puts
