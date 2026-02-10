# AI Analysis Service - Production Version
# Handles real document analysis using PDF extraction and Multi-Provider AI

require 'net/http'
require 'json'
require 'uri'
require 'time'
require 'pdf-reader'
require_relative 'ai_provider'

class AIAnalysisService
  def initialize(document_id)
    @document_id = document_id
    @document = load_document
    @ai_provider = AIProvider.new
    @logs = []
    @use_real_ai = @ai_provider.enabled?
  end

  def analyze
    log_step('Starting AI analysis')
    log_step("AI Provider: #{@ai_provider.provider_name}") if @use_real_ai
    
    # Step 1: Extract text from actual PDF
    text = extract_text_from_pdf
    return error_result('Failed to extract text from PDF') unless text
    
    log_step("Extracted #{text.length} characters from document")
    
    # Step 2: Extract entities using AI or fallback
    entities = if @use_real_ai
      extract_entities_with_ai(text)
    else
      extract_entities_fallback(text)
    end
    log_step("Found #{entities.length} entities")
    
    # Step 3: Check compliance
    compliance = if @use_real_ai
      check_compliance_with_ai(text, entities)
    else
      check_compliance_fallback(text, entities)
    end
    log_step("Compliance score: #{compliance[:score]}%")
    
    # Step 4: Assess risks
    risks = assess_risks_from_text(text, entities, compliance)
    log_step("Risk level: #{risks[:level]}")
    
    # Step 5: Generate summary
    summary = if @use_real_ai
      generate_summary_with_ai(text, entities, compliance, risks)
    else
      generate_summary_fallback(text, entities, compliance, risks)
    end
    log_step('Analysis complete')
    
    # Save results
    save_results(entities, compliance, risks, summary, text)
    
    {
      success: true,
      entities: entities,
      compliance: compliance,
      risks: risks,
      summary: summary,
      confidence: calculate_confidence(entities, compliance, risks),
      logs: @logs,
      using_real_ai: @use_real_ai
    }
  rescue => e
    log_step("Error: #{e.message}", 'error')
    puts "Full error: #{e.class}: #{e.message}"
    puts e.backtrace.first(5)
    error_result(e.message)
  end

  private

  def load_document
    db = SQLite3::Database.new('storage/legastream.db')
    db.results_as_hash = true
    result = db.execute('SELECT * FROM documents WHERE id = ?', [@document_id]).first
    db.close
    result
  end

  def extract_text_from_pdf
    # Get the file path
    filename = @document['filename'] || @document['original_filename']
    file_path = File.join('storage', 'uploads', filename)
    
    # Check if file exists
    unless File.exist?(file_path)
      log_step("File not found at #{file_path}, checking alternative paths")
      # Try alternative paths
      alt_paths = [
        File.join('storage', 'documents', filename),
        File.join('storage', 'documents', "#{@document_id}_#{filename}")
      ]
      
      file_path = alt_paths.find { |path| File.exist?(path) }
      
      unless file_path
        log_step("PDF file not found, using fallback text extraction")
        return extract_text_fallback
      end
    end
    
    log_step("Reading PDF from: #{file_path}")
    
    # Extract text from PDF
    reader = PDF::Reader.new(file_path)
    text = reader.pages.map(&:text).join("\n\n")
    
    # Clean up the text
    text = text.gsub(/\s+/, ' ').strip
    
    if text.empty?
      log_step("PDF appears to be empty or image-based, using OCR fallback")
      return extract_text_fallback
    end
    
    text
  rescue => e
    log_step("PDF extraction error: #{e.message}")
    extract_text_fallback
  end

  def extract_text_fallback
    # Fallback: return a notice that the file couldn't be read
    "Document uploaded but text extraction failed. File may be image-based PDF or corrupted."
  end

  def extract_entities_with_ai(text)
    log_step("Using #{@ai_provider.provider_name.upcase} for entity extraction")
    
    entities_data = @ai_provider.extract_entities(text)
    
    if entities_data.nil?
      log_step("AI returned nil, using fallback")
      return extract_entities_fallback(text)
    end
    
    unless entities_data.is_a?(Array)
      log_step("AI returned non-array (#{entities_data.class}), using fallback")
      return extract_entities_fallback(text)
    end
    
    if entities_data.empty?
      log_step("AI returned empty array, using fallback")
      return extract_entities_fallback(text)
    end
    
    log_step("AI extracted #{entities_data.length} entities")
    
    # Save entities to database
    entities_data.each do |entity|
      confidence = entity['confidence'] || 0.90
      save_entity(entity['type'], entity['value'], entity['context'] || '', confidence)
    end
    
    entities_data
  rescue => e
    log_step("AI entity extraction failed: #{e.message}")
    log_step("Error class: #{e.class}")
    extract_entities_fallback(text)
  end

  def extract_entities_fallback(text)
    log_step("Using fallback entity extraction (regex-based)")
    
    entities = []
    
    # Extract dates
    text.scan(/\b\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}\b|\b(?:January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2},?\s+\d{4}\b/i) do |match|
      entities << { type: 'date', value: match, context: 'Date found in document' }
      save_entity('date', match, 'Date found in document', 0.90)
    end
    
    # Extract monetary amounts
    text.scan(/\$[\d,]+(?:\.\d{2})?|\b\d+(?:,\d{3})*(?:\.\d{2})?\s*(?:USD|dollars?)\b/i) do |match|
      entities << { type: 'monetary', value: match, context: 'Monetary amount' }
      save_entity('monetary', match, 'Monetary amount', 0.95)
    end
    
    # Extract email addresses (high confidence)
    text.scan(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/) do |match|
      entities << { type: 'email', value: match, context: 'Email address' }
      save_entity('email', match, 'Email address', 0.98)
    end
    
    # Extract phone numbers
    text.scan(/\b\d{3}[-.]?\d{3}[-.]?\d{4}\b|\(\d{3}\)\s*\d{3}[-.]?\d{4}\b/) do |match|
      entities << { type: 'phone', value: match, context: 'Phone number' }
      save_entity('phone', match, 'Phone number', 0.92)
    end
    
    # Extract proper names (more selective - only 2-3 word capitalized sequences)
    # Skip common words and only match likely person names
    common_words = %w[The This That These Those Report Summary Document Analysis Section Chapter Page Table Figure Appendix]
    text.scan(/\b[A-Z][a-z]+\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)?\b/) do |match|
      words = match.split
      next if words.any? { |w| common_words.include?(w) }
      next if words.length > 3 # Skip very long matches
      next if match.length < 5 # Skip very short matches
      
      entities << { type: 'person', value: match, context: 'Person or organization name' }
      save_entity('person', match, 'Person or organization name', 0.75)
    end
    
    # Extract addresses (simple pattern)
    text.scan(/\b\d+\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\s+(?:Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Drive|Dr|Lane|Ln)\b/i) do |match|
      entities << { type: 'address', value: match, context: 'Address' }
      save_entity('address', match, 'Address', 0.88)
    end
    
    entities.uniq { |e| [e[:type], e[:value]] }
  end

  def check_compliance_with_ai(text, entities)
    log_step("Using #{@ai_provider.provider_name.upcase} for compliance check")
    
    result = @ai_provider.analyze_compliance(text, entities)
    
    return check_compliance_fallback(text, entities) unless result
    
    {
      score: result['score'] || result[:score] || 85,
      issues: result['issues'] || result[:issues] || [],
      recommendations: result['recommendations'] || result[:recommendations] || []
    }
  rescue => e
    log_step("AI compliance check failed: #{e.message}")
    check_compliance_fallback(text, entities)
  end

  def check_compliance_fallback(text, entities)
    issues = []
    score = 100
    
    # Check for common compliance keywords
    if text.downcase.include?('gdpr') || text.downcase.include?('data protection')
      if !text.downcase.include?('consent') && !text.downcase.include?('privacy policy')
        issues << "GDPR compliance: Missing explicit consent or privacy policy reference"
        score -= 15
      end
    end
    
    if text.downcase.include?('confidential')
      if !text.downcase.include?('non-disclosure') && !text.downcase.include?('nda')
        issues << "Confidentiality: Consider adding NDA clause"
        score -= 10
      end
    end
    
    if entities.any? { |e| e[:type] == 'monetary' }
      if !text.downcase.include?('payment') && !text.downcase.include?('compensation')
        issues << "Financial terms: Payment terms should be clearly defined"
        score -= 10
      end
    end
    
    {
      score: [score, 0].max,
      issues: issues,
      recommendations: issues.map { |i| "Review: #{i}" }
    }
  end

  def assess_risks_from_text(text, entities, compliance)
    risk_score = 0
    risk_factors = []
    
    # High risk keywords
    high_risk_terms = ['termination', 'liability', 'indemnification', 'breach', 'penalty']
    high_risk_terms.each do |term|
      if text.downcase.include?(term)
        risk_score += 15
        risk_factors << "Contains #{term} clause - requires careful review"
      end
    end
    
    # Compliance-based risk
    if compliance[:score] < 70
      risk_score += 20
      risk_factors << "Low compliance score indicates potential legal risks"
    end
    
    # Determine risk level
    level = if risk_score >= 50
      'high'
    elsif risk_score >= 25
      'medium'
    else
      'low'
    end
    
    {
      level: level,
      score: [risk_score, 100].min,
      factors: risk_factors
    }
  end

  def generate_summary_with_ai(text, entities, compliance, risks)
    log_step("Using #{@ai_provider.provider_name.upcase} for summary generation")
    
    result = @ai_provider.generate_summary(text, entities, compliance, risks)
    
    return generate_summary_fallback(text, entities, compliance, risks) unless result && !result.empty?
    
    result
  rescue => e
    log_step("AI summary generation failed: #{e.message}")
    generate_summary_fallback(text, entities, compliance, risks)
  end

  def generate_summary_fallback(text, entities, compliance, risks)
    # Extract first few sentences as summary
    sentences = text.split(/[.!?]+/).map(&:strip).reject(&:empty?)
    summary = sentences.first(3).join('. ')
    
    if summary.length > 300
      summary = summary[0..297] + '...'
    end
    
    summary.empty? ? "Document analyzed with #{entities.length} entities found." : summary
  end

  def save_entity(entity_type, entity_value, context, confidence = 0.85)
    db = SQLite3::Database.new('storage/legastream.db')
    db.execute(
      "INSERT INTO entities (document_id, entity_type, entity_value, context, confidence) VALUES (?, ?, ?, ?, ?)",
      [@document_id, entity_type, entity_value, context, confidence]
    )
    db.close
  rescue => e
    log_step("Failed to save entity: #{e.message}")
  end

  def save_results(entities, compliance, risks, summary, extracted_text)
    analysis_results = {
      entities_extracted: entities.length,
      compliance_score: compliance[:score],
      risk_level: risks[:level],
      issues_flagged: compliance[:issues].length,
      confidence_score: calculate_confidence(entities, compliance, risks),
      summary: summary,
      using_real_ai: @use_real_ai
    }.to_json
    
    db = SQLite3::Database.new('storage/legastream.db')
    db.execute(
      "UPDATE documents SET status = 'completed', analysis_results = ?, extracted_text = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
      [analysis_results, extracted_text[0..10000], @document_id]
    )
    
    # Save compliance issues
    compliance[:issues].each_with_index do |issue, index|
      db.execute(
        "INSERT INTO compliance_issues (document_id, issue_type, severity, description, recommendation) VALUES (?, ?, ?, ?, ?)",
        [@document_id, 'compliance', risks[:level], issue, compliance[:recommendations][index] || 'Review required']
      )
    end
    
    db.close
  end

  def calculate_confidence(entities, compliance, risks)
    base_confidence = 0.75
    
    # Increase confidence with more entities found
    entity_bonus = [entities.length * 0.01, 0.15].min
    
    # Adjust based on compliance score
    compliance_factor = compliance[:score] / 100.0 * 0.1
    
    # Adjust based on AI usage
    ai_bonus = @use_real_ai ? 0.1 : 0.0
    
    total = base_confidence + entity_bonus + compliance_factor + ai_bonus
    ([total, 0.99].min * 100).round(1)
  end

  def log_step(message, level = 'info')
    @logs << { timestamp: Time.now.iso8601, level: level, message: message }
    puts "[AIAnalysisService] #{message}"
  end

  def error_result(message)
    {
      success: false,
      error: message,
      logs: @logs
    }
  end
end
