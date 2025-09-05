# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: "OK"
    end
  end

  describe "browser compatibility" do
    it "allows all browsers" do
      get :index
      expect(response).to be_successful
    end

    it "does not restrict browser versions" do
      # The allow_browser versions: :modern line is commented out
      # so all browsers should be allowed
      get :index
      expect(response).to be_successful
    end
  end
end
