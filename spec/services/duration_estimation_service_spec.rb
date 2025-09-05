# frozen_string_literal: true

require "rails_helper"

RSpec.describe DurationEstimationService do
  let(:gemini_service) { instance_double(GeminiService) }
  let(:service) { described_class.new(gemini_service) }

  describe "#initialize" do
    context "when gemini_service is provided" do
      it "uses the provided gemini_service" do
        expect(service.instance_variable_get(:@gemini_service)).to eq(gemini_service)
      end
    end

    context "when gemini_service is not provided" do
      it "creates a new GeminiService instance" do
        allow(GeminiService).to receive(:new).and_return(gemini_service)
        service = described_class.new
        expect(service.instance_variable_get(:@gemini_service)).to eq(gemini_service)
      end
    end
  end

  describe "#estimate_duration" do
    let(:task_name) { "Implement user authentication" }
    let(:task_description) { "Add login and registration functionality" }
    let(:gemini_response) { "2 hours" }

    before do
      allow(gemini_service).to receive(:generate_content).and_return(gemini_response)
    end

    context "with task name only" do
      it "calls gemini service with correct prompt" do
        expected_prompt = "Estimate the time duration for this task. Respond with ONLY a duration in one of these formats: 'X minutes', 'X hours', 'X days', or 'X weeks'. Be realistic and consider typical work patterns.\n\nTask: #{task_name}\n\nExamples of good responses: '30 minutes', '2 hours', '1 day', '3 days', '1 week'"

        service.estimate_duration(task_name)

        expect(gemini_service).to have_received(:generate_content).with(
          expected_prompt,
          {
            generation_config: {
              temperature: 0.3,
              max_output_tokens: 100
            }
          }
        )
      end

      it "returns the parsed duration" do
        result = service.estimate_duration(task_name)
        expect(result).to eq("2 hours")
      end
    end

    context "with task name and description" do
      it "calls gemini service with correct prompt including description" do
        expected_prompt = "Estimate the time duration for this task. Respond with ONLY a duration in one of these formats: 'X minutes', 'X hours', 'X days', or 'X weeks'. Be realistic and consider typical work patterns.\n\nTask: #{task_name}\n\nDescription: #{task_description}\n\nExamples of good responses: '30 minutes', '2 hours', '1 day', '3 days', '1 week'"

        service.estimate_duration(task_name, task_description)

        expect(gemini_service).to have_received(:generate_content).with(
          expected_prompt,
          {
            generation_config: {
              temperature: 0.3,
              max_output_tokens: 100
            }
          }
        )
      end

      it "returns the parsed duration" do
        result = service.estimate_duration(task_name, task_description)
        expect(result).to eq("2 hours")
      end
    end

    context "when gemini service returns error" do
      before do
        allow(gemini_service).to receive(:generate_content).and_return("Unable to process request")
      end

      it "returns error message" do
        result = service.estimate_duration(task_name)
        expect(result).to eq("Unable to estimate duration")
      end
    end

    context "with different response formats" do
      test_cases = [
        { response: "2 hours", expected: "2 hours" },
        { response: "30 minutes", expected: "30 minutes" },
        { response: "1 day", expected: "1 day" },
        { response: "3 days", expected: "3 days" },
        { response: "1 week", expected: "1 week" },
        { response: "About 2 hours", expected: "About 2 hours" },
        { response: "2-3 hours", expected: "2-3 hours" },
        { response: "2 hours (estimated)", expected: "2 hours estimated" }
      ]

      test_cases.each do |test_case|
        context "when response is '#{test_case[:response]}'" do
          before do
            allow(gemini_service).to receive(:generate_content).and_return(test_case[:response])
          end

          it "returns '#{test_case[:expected]}'" do
            result = service.estimate_duration(task_name)
            expect(result).to eq(test_case[:expected])
          end
        end
      end
    end
  end

  describe "#build_prompt" do
    let(:task_name) { "Test task" }

    context "with task name only" do
      it "builds prompt without description" do
        result = service.send(:build_prompt, task_name, nil)
        expect(result).to include("Task: #{task_name}")
        expect(result).not_to include("Description:")
      end
    end

    context "with task name and description" do
      let(:description) { "Test description" }

      it "builds prompt with description" do
        result = service.send(:build_prompt, task_name, description)
        expect(result).to include("Task: #{task_name}")
        expect(result).to include("Description: #{description}")
      end
    end

    context "with empty description" do
      it "builds prompt without description section" do
        result = service.send(:build_prompt, task_name, "")
        expect(result).to include("Task: #{task_name}")
        expect(result).not_to include("Description:")
      end
    end

    it "includes format instructions" do
      result = service.send(:build_prompt, task_name, nil)
      expect(result).to include("Respond with ONLY a duration")
      expect(result).to include("X minutes", "X hours", "X days", "X weeks")
    end

    it "includes examples" do
      result = service.send(:build_prompt, task_name, nil)
      expect(result).to include("Examples of good responses")
      expect(result).to include("30 minutes", "2 hours", "1 day", "3 days", "1 week")
    end
  end

  describe "#parse_duration_response" do
    context "when response is error message" do
      it "returns error message" do
        result = service.send(:parse_duration_response, "Unable to process request")
        expect(result).to eq("Unable to estimate duration")
      end
    end

    context "when response contains special characters" do
      test_cases = [
        { input: "2 hours!", expected: "2 hours" },
        { input: "30 minutes?", expected: "30 minutes" },
        { input: "1 day.", expected: "1 day" },
        { input: "3 days (estimated)", expected: "3 days estimated" },
        { input: "2-3 hours", expected: "2-3 hours" },
        { input: "About 2 hours", expected: "About 2 hours" }
      ]

      test_cases.each do |test_case|
        it "removes special characters from '#{test_case[:input]}'" do
          result = service.send(:parse_duration_response, test_case[:input])
          expect(result).to eq(test_case[:expected])
        end
      end
    end

    context "when response has extra whitespace" do
      it "strips whitespace" do
        result = service.send(:parse_duration_response, "  2 hours  ")
        expect(result).to eq("2 hours")
      end
    end

    context "when response is clean" do
      it "returns response as is" do
        result = service.send(:parse_duration_response, "2 hours")
        expect(result).to eq("2 hours")
      end
    end
  end
end
