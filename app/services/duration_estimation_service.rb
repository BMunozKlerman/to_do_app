class DurationEstimationService
  def initialize(gemini_service = nil)
    @gemini_service = gemini_service || GeminiService.new
  end

  def estimate_duration(task_name, task_description = nil)
    prompt = build_prompt(task_name, task_description)

    response = @gemini_service.generate_content(prompt, {
      generation_config: {
        temperature: 0.3,
        max_output_tokens: 100
      }
    })

    parse_duration_response(response)
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
    return "Unable to estimate duration" if response == "Unable to process request"

    # Clean up the response to extract just the duration, preserving hyphens and common punctuation
    response.gsub(/[^\w\s\-]/, "").strip
  end
end
