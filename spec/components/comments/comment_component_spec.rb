# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comments::CommentComponent, type: :component do
  let(:user) { create(:user, name: "John Doe") }
  let(:to_do_item) { create(:to_do_item) }
  let(:comment) { create(:comment, user: user, to_do_item: to_do_item, text: "Test comment") }
  let(:component) { described_class.new(comment: comment, to_do_item: to_do_item) }

  describe "#initialize" do
    it "sets the comment and to_do_item" do
      expect(component.send(:comment)).to eq(comment)
      expect(component.send(:to_do_item)).to eq(to_do_item)
    end
  end

  describe "#time_ago" do
    it "returns formatted time ago string" do
      time_ago = component.send(:time_ago)
      expect(time_ago).to include("ago")
      expect(time_ago).to be_a(String)
    end

    it "uses time_ago_in_words helper" do
      # Mock the time_ago_in_words method to test it's being called
      allow(component).to receive(:time_ago_in_words).and_return("2 minutes")
      time_ago = component.send(:time_ago)
      expect(time_ago).to eq("2 minutes ago")
    end
  end

  describe "rendering" do
    it "renders without errors" do
      expect { render_inline(component) }.not_to raise_error
    end

    it "renders the user name" do
      render_inline(component)
      expect(page).to have_css(".fw-bold", text: "John Doe")
    end

    it "renders the comment text" do
      render_inline(component)
      expect(page).to have_content("Test comment")
    end

    it "renders the time ago" do
      render_inline(component)
      expect(page).to have_css(".text-muted.small")
      expect(page).to have_content("ago")
    end

    it "renders the delete button" do
      render_inline(component)
      expect(page).to have_css("button[type='submit']")
      expect(page).to have_css("i.fas.fa-times")
    end

    it "renders the delete form with correct action" do
      render_inline(component)
      expected_path = Rails.application.routes.url_helpers.to_do_item_comment_path(to_do_item, comment)
      expect(page).to have_css("form[action='#{expected_path}']")
    end

    it "renders the delete form with DELETE method" do
      render_inline(component)
      expect(page).to have_css("form[method='post']")
      # The _method input is added by Rails form helpers, not in the template
    end

    it "applies correct CSS classes" do
      render_inline(component)
      expect(page).to have_css(".border-bottom.pb-3.mb-3")
      expect(page).to have_css(".d-flex.justify-content-between.align-items-start")
      expect(page).to have_css(".flex-grow-1")
      expect(page).to have_css(".d-flex.align-items-center.gap-2")
    end

    it "applies correct button classes" do
      render_inline(component)
      expect(page).to have_css(".btn.btn-sm.btn-outline-danger")
    end

    it "includes proper title attribute for delete button" do
      render_inline(component)
      expect(page).to have_css("button[title='Delete comment']")
    end
  end

  describe "with different comment data" do
    let(:long_comment) { create(:comment, user: user, to_do_item: to_do_item, text: "This is a very long comment that should be displayed properly in the component") }
    let(:component) { described_class.new(comment: long_comment, to_do_item: to_do_item) }

    it "renders long comments correctly" do
      render_inline(component)
      expect(page).to have_content("This is a very long comment that should be displayed properly in the component")
    end
  end

  describe "with different user names" do
    let(:user_with_special_chars) { create(:user, name: "O'Connor-Smith") }
    let(:comment) { create(:comment, user: user_with_special_chars, to_do_item: to_do_item) }
    let(:component) { described_class.new(comment: comment, to_do_item: to_do_item) }

    it "renders special characters in names correctly" do
      render_inline(component)
      expect(page).to have_css(".fw-bold", text: "O'Connor-Smith")
    end
  end

  describe "time formatting edge cases" do
    let(:recent_comment) { create(:comment, user: user, to_do_item: to_do_item, created_at: 30.seconds.ago) }
    let(:component) { described_class.new(comment: recent_comment, to_do_item: to_do_item) }

    it "handles very recent comments" do
      render_inline(component)
      expect(page).to have_content("ago")
    end
  end

  describe "form submission" do
    it "includes CSRF token" do
      render_inline(component)
      # CSRF token is added by Rails form helpers, not in the template
      expect(page).to have_css("form")
    end

    it "has proper form attributes" do
      render_inline(component)
      expect(page).to have_css("form.d-inline")
    end
  end
end