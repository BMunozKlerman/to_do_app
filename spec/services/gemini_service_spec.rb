# frozen_string_literal: true

require "rails_helper"

RSpec.describe GeminiService do
  let(:api_key) { "test_api_key" }
  let(:service) { described_class.new(api_key) }

  describe "#initialize" do
    context "when api_key is provided" do
      it "uses the provided api_key" do
        expect(service.instance_variable_get(:@api_key)).to eq(api_key)
      end
    end

    context "when api_key is not provided" do
      before do
        allow(ENV).to receive(:[]).with("GEMINI_API_KEY").and_return("env_api_key")
      end

      it "uses the environment variable" do
        service = described_class.new
        expect(service.instance_variable_get(:@api_key)).to eq("env_api_key")
      end
    end

    context "when no api_key is available" do
      before do
        allow(ENV).to receive(:[]).with("GEMINI_API_KEY").and_return(nil)
      end

      it "raises an error" do
        expect { described_class.new }.to raise_error("Gemini API key not found. Please set GEMINI_API_KEY environment variable.")
      end
    end
  end

  describe "#generate_content" do
    let(:prompt) { "Test prompt" }
    let(:successful_response) do
      {
        "candidates" => [
          {
            "content" => {
              "parts" => [
                { "text" => "Test response" }
              ]
            }
          }
        ]
      }
    end

    before do
      allow(service.class).to receive(:post).and_return(double(success?: true, parsed_response: successful_response))
    end

    context "with default options" do
      it "makes a request with default generation config" do
        expected_body = {
          contents: [ { parts: [ { text: prompt } ] } ],
          generationConfig: {
            temperature: 0.3,
            max_output_tokens: 1000
          }
        }

        service.generate_content(prompt)

        expect(service.class).to have_received(:post).with(
          "/models/gemini-1.5-flash:generateContent",
          headers: { "Content-Type" => "application/json" },
          query: { key: api_key },
          body: expected_body.to_json
        )
      end
    end

    context "with custom options" do
      let(:custom_options) do
        {
          generation_config: {
            temperature: 0.7,
            max_output_tokens: 500
          }
        }
      end

      it "merges custom options with defaults" do
        expected_body = {
          contents: [ { parts: [ { text: prompt } ] } ],
          generationConfig: {
            temperature: 0.7,
            max_output_tokens: 500
          }
        }

        service.generate_content(prompt, custom_options)

        expect(service.class).to have_received(:post).with(
          "/models/gemini-1.5-flash:generateContent",
          headers: { "Content-Type" => "application/json" },
          query: { key: api_key },
          body: expected_body.to_json
        )
      end
    end

    context "when request is successful" do
      it "returns the parsed response text" do
        result = service.generate_content(prompt)
        expect(result).to eq("Test response")
      end
    end

    context "when request fails" do
      before do
        allow(service.class).to receive(:post).and_return(
          double(success?: false, code: 400, body: "Bad Request")
        )
        allow(Rails.logger).to receive(:error)
      end

      it "logs the error and returns error message" do
        result = service.generate_content(prompt)

        expect(Rails.logger).to have_received(:error).with("Gemini API error: 400 - Bad Request")
        expect(result).to eq("Unable to process request")
      end
    end

    context "when an exception occurs" do
      before do
        allow(service.class).to receive(:post).and_raise(StandardError.new("Network error"))
        allow(Rails.logger).to receive(:error)
      end

      it "logs the error and returns error message" do
        result = service.generate_content(prompt)

        expect(Rails.logger).to have_received(:error).with("Gemini service error: Network error")
        expect(result).to eq("Unable to process request")
      end
    end
  end

  describe "#parse_response" do
    context "with valid response structure" do
      let(:response) do
        {
          "candidates" => [
            {
              "content" => {
                "parts" => [
                  { "text" => "  Test response  " }
                ]
              }
            }
          ]
        }
      end

      it "returns the stripped text" do
        result = service.send(:parse_response, response)
        expect(result).to eq("Test response")
      end
    end

    context "with missing candidates" do
      let(:response) { {} }

      it "returns error message" do
        result = service.send(:parse_response, response)
        expect(result).to eq("Unable to process request")
      end
    end

    context "with missing content" do
      let(:response) { { "candidates" => [ {} ] } }

      it "returns error message" do
        result = service.send(:parse_response, response)
        expect(result).to eq("Unable to process request")
      end
    end

    context "with missing parts" do
      let(:response) { { "candidates" => [ { "content" => {} } ] } }

      it "returns error message" do
        result = service.send(:parse_response, response)
        expect(result).to eq("Unable to process request")
      end
    end

    context "with missing text" do
      let(:response) { { "candidates" => [ { "content" => { "parts" => [ {} ] } } ] } }

      it "returns error message" do
        result = service.send(:parse_response, response)
        expect(result).to eq("Unable to process request")
      end
    end

    context "with nil response" do
      it "returns error message" do
        result = service.send(:parse_response, nil)
        expect(result).to eq("Unable to process request")
      end
    end
  end
end
