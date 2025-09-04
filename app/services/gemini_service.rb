require "httparty"

class GeminiService
  include HTTParty
  base_uri "https://generativelanguage.googleapis.com/v1beta"

  def initialize(api_key = nil)
    @api_key = api_key || ENV["GEMINI_API_KEY"]
    raise "Gemini API key not found. Please set GEMINI_API_KEY environment variable." unless @api_key
  end

  def generate_content(prompt, options = {})
    default_options = {
      temperature: 0.3,
      max_output_tokens: 1000
    }

    generation_config = default_options.merge(options[:generation_config] || {})

    response = self.class.post(
      "/models/gemini-1.5-flash:generateContent",
      headers: { "Content-Type" => "application/json" },
      query: { key: @api_key },
      body: {
        contents: [
          {
            parts: [
              { text: prompt }
            ]
          }
        ],
        generationConfig: generation_config
      }.to_json
    )

    if response.success?
      parse_response(response.parsed_response)
    else
      Rails.logger.error "Gemini API error: #{response.code} - #{response.body}"
      "Unable to process request"
    end
  rescue => e
    Rails.logger.error "Gemini service error: #{e.message}"
    "Unable to process request"
  end

  private

  def parse_response(response)
    return "Unable to process request" unless response&.dig("candidates")&.first&.dig("content")&.dig("parts")&.first&.dig("text")

    response["candidates"].first["content"]["parts"].first["text"].strip
  end
end
