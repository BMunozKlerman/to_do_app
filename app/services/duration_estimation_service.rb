require "httparty"

class DurationEstimationService
  include HTTParty
  base_uri "https://generativelanguage.googleapis.com/v1beta"

  def initialize(api_key = nil)
    @api_key = api_key || ENV["GEMINI_API_KEY"]
    raise "Gemini API key not found. Please set GEMINI_API_KEY environment variable." unless @api_key
  end

  def estimate_duration(task_name, task_description = nil)
    prompt = build_prompt(task_name, task_description)

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
        generationConfig: {
          temperature: 0.3,
          maxOutputTokens: 100
        }
      }.to_json
    )

    if response.success?
      parse_duration_response(response.parsed_response)
    else
      Rails.logger.error "Gemini API error: #{response.code} - #{response.body}"
      "Unable to estimate duration"
    end
  rescue => e
    Rails.logger.error "Duration estimation error: #{e.message}"
    "Unable to estimate duration"
  end

  private

  def build_prompt(task_name, task_description)
    base_prompt = "Estimate the time duration for this task. Respond with ONLY a duration in one of these formats: 'X minutes', 'X hours', 'X days', or 'X weeks'. Be realistic and consider typical work patterns.

Task: #{task_name}"

    if task_description.present?
      base_prompt += "\n\nDescription: #{task_description}"
    end

    base_prompt += "\n\nExamples of good responses: '30 minutes', '2 hours', '1 day', '3 days', '1 week'"
    base_prompt
  end

  def parse_duration_response(response)
    return "Unable to estimate duration" unless response&.dig("candidates")&.first&.dig("content")&.dig("parts")&.first&.dig("text")

    duration_text = response["candidates"].first["content"]["parts"].first["text"].strip

    # Clean up the response to extract just the duration
    duration_text.gsub(/[^\w\s]/, "").strip
  end
end
