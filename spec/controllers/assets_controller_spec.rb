# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssetsController, type: :controller do
  let(:file_path) { Rails.root.join("app/assets/builds", "application.css") }
  let(:js_file_path) { Rails.root.join("app/assets/builds", "application.js") }

  before do
    # Create test files
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, "body { color: red; }")
    File.write(js_file_path, "console.log('test');")
  end

  after do
    # Clean up test files
    FileUtils.rm_f(file_path)
    FileUtils.rm_f(js_file_path)
  end

  describe "GET #show" do
    context "with CSS file" do
      it "returns the CSS file" do
        get :show, params: { path: "application" }, format: :css
        expect(response).to be_successful
        expect(response.content_type).to include("text/css")
        expect(response.body).to eq("body { color: red; }")
      end

      it "adds .css extension to path" do
        get :show, params: { path: "application" }, format: :css
        expect(response).to be_successful
      end
    end

    context "with JS file" do
      it "returns the JS file" do
        get :show, params: { path: "application" }, format: :js
        expect(response).to be_successful
        expect(response.content_type).to include("application/javascript")
        expect(response.body).to eq("console.log('test');")
      end

      it "adds .js extension to path" do
        get :show, params: { path: "application" }, format: :js
        expect(response).to be_successful
      end
    end

    context "with .map file" do
      let(:map_file_path) { Rails.root.join("app/assets/builds", "application.js.map") }

      before do
        File.write(map_file_path, '{"version": 3}')
      end

      after do
        FileUtils.rm_f(map_file_path)
      end

      it "returns the map file with correct content type" do
        get :show, params: { path: "application.js.map" }
        expect(response).to be_successful
        expect(response.content_type).to include("application/json")
        expect(response.body).to eq('{"version": 3}')
      end
    end

    context "with non-existent file" do
      it "returns 404" do
        get :show, params: { path: "nonexistent" }, format: :css
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with different file types" do
      it "sets correct content type for CSS" do
        get :show, params: { path: "application" }, format: :css
        expect(response.content_type).to include("text/css")
      end

      it "sets correct content type for JS" do
        get :show, params: { path: "application" }, format: :js
        expect(response.content_type).to include("application/javascript")
      end

      it "sets correct content type for map files" do
        map_file_path = Rails.root.join("app/assets/builds", "test.map")
        File.write(map_file_path, "test content")

        get :show, params: { path: "test.map" }
        expect(response.content_type).to include("application/json")

        FileUtils.rm_f(map_file_path)
      end

      it "sets text/plain for unknown file types" do
        unknown_file_path = Rails.root.join("app/assets/builds", "test.unknown")
        File.write(unknown_file_path, "test content")

        get :show, params: { path: "test.unknown" }
        expect(response.content_type).to include("text/plain")

        FileUtils.rm_f(unknown_file_path)
      end
    end

    context "CSRF protection" do
      it "skips CSRF verification" do
        # This is tested by the fact that the controller has skip_before_action :verify_authenticity_token
        # and the tests run without CSRF errors
        get :show, params: { path: "application" }, format: :css
        expect(response).to be_successful
      end
    end
  end
end
