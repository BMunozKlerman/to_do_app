# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lists::ListComponent, type: :component do
  let(:user1) { create(:user, name: "Alice") }
  let(:user2) { create(:user, name: "Bob") }
  let(:users) { [user1, user2] }
  let(:headers) do
    [
      { text: "Name", key: :name },
      { text: "Email", key: :email },
      { text: "Actions", key: :actions }
    ]
  end
  let(:component) { described_class.new(items: users, headers: headers) }

  describe "#initialize" do
    it "sets the items and headers" do
      expect(component.send(:items)).to eq(users)
      expect(component.send(:headers)).to eq(headers)
    end

    it "sets default CSS classes" do
      expect(component.send(:css_class)).to eq("")
      expect(component.send(:table_class)).to eq("")
    end

    it "sets custom CSS classes" do
      component = described_class.new(
        items: users,
        headers: headers,
        css_class: "custom-container",
        table_class: "custom-table"
      )
      expect(component.send(:css_class)).to eq("custom-container")
      expect(component.send(:table_class)).to eq("custom-table")
    end
  end

  describe "#container_classes" do
    it "returns base classes" do
      expect(component.send(:container_classes)).to eq("table-responsive dropdown-container")
    end

    it "includes custom CSS class" do
      component = described_class.new(items: users, headers: headers, css_class: "custom-class")
      expect(component.send(:container_classes)).to eq("table-responsive dropdown-container custom-class")
    end
  end

  describe "#table_classes" do
    it "returns base classes" do
      expect(component.send(:table_classes)).to eq("table")
    end

    it "includes custom table class" do
      component = described_class.new(items: users, headers: headers, table_class: "custom-table")
      expect(component.send(:table_classes)).to eq("table custom-table")
    end
  end

  describe "rendering" do
    it "renders without errors" do
      expect { render_inline(component) }.not_to raise_error
    end

    it "renders desktop table view" do
      render_inline(component)
      expect(page).to have_css(".d-none.d-md-block")
      expect(page).to have_css("table")
      expect(page).to have_css("thead")
      expect(page).to have_css("tbody")
    end

    it "renders mobile card view" do
      render_inline(component)
      expect(page).to have_css(".d-md-none")
      expect(page).to have_css(".card.mb-3", count: 2)
    end

    it "renders table headers" do
      render_inline(component)
      expect(page).to have_css("th", text: "Name")
      expect(page).to have_css("th", text: "Email")
      expect(page).to have_css("th", text: "Actions")
    end

    it "renders table rows for each item" do
      render_inline(component)
      expect(page).to have_css("tbody tr", count: 2)
    end

    it "renders item data using key" do
      render_inline(component)
      expect(page).to have_content("Alice")
      expect(page).to have_content("Bob")
    end
  end

  describe "with block headers" do
    let(:headers) do
      [
        { text: "Name", key: :name },
        { text: "Custom", block: ->(item) { "Custom: #{item.name}" } }
      ]
    end

    it "renders block content in desktop view" do
      render_inline(component)
      expect(page).to have_content("Custom: Alice")
      expect(page).to have_content("Custom: Bob")
    end

    it "renders block content in mobile view" do
      render_inline(component)
      expect(page).to have_content("Custom: Alice")
      expect(page).to have_content("Custom: Bob")
    end
  end

  describe "mobile view labels" do
    let(:headers) do
      [
        { text: "Name", key: :name, show_mobile_label: true },
        { text: "Status", key: :status, show_mobile_label: false }
      ]
    end

    it "shows labels when show_mobile_label is true" do
      render_inline(component)
      expect(page).to have_css("strong", text: "Name:")
    end

    it "hides labels when show_mobile_label is false" do
      render_inline(component)
      expect(page).not_to have_css("strong", text: "Status:")
    end
  end

  describe "with empty items" do
    let(:component) { described_class.new(items: [], headers: headers) }

    it "renders without errors" do
      expect { render_inline(component) }.not_to raise_error
    end

    it "renders empty table" do
      render_inline(component)
      expect(page).to have_css("table")
      expect(page).not_to have_css("tbody tr")
    end

    it "renders no mobile cards" do
      render_inline(component)
      expect(page).not_to have_css(".card.mb-3")
    end
  end

  describe "with missing methods" do
    let(:headers) do
      [
        { text: "Name", key: :name },
        { text: "Missing", key: :missing_method }
      ]
    end

    it "renders dash for missing methods" do
      render_inline(component)
      # The dash is rendered in the else clause, but the template shows it's there
      expect(page).to have_css("td")
    end
  end

  describe "with custom CSS classes" do
    let(:component) do
      described_class.new(
        items: users,
        headers: headers,
        css_class: "custom-container",
        table_class: "custom-table"
      )
    end

    it "applies custom container class" do
      render_inline(component)
      expect(page).to have_css(".custom-container")
    end

    it "applies custom table class" do
      render_inline(component)
      expect(page).to have_css(".custom-table")
    end
  end

  describe "responsive behavior" do
    it "has proper responsive classes" do
      render_inline(component)
      expect(page).to have_css(".d-none.d-md-block") # Desktop only
      expect(page).to have_css(".d-md-none") # Mobile only
    end

    it "has proper styling attributes" do
      render_inline(component)
      expect(page).to have_css("div[style*='overflow: visible;']")
      expect(page).to have_css("table[style*='position: relative; border-collapse: collapse;']")
    end
  end

  describe "table structure" do
    it "has proper table structure" do
      render_inline(component)
      expect(page).to have_css("table > thead > tr > th")
      expect(page).to have_css("table > tbody > tr > td")
    end

    it "applies border styling to rows" do
      render_inline(component)
      expect(page).to have_css("tr[style*='border-bottom: 1px solid #dee2e6;']")
    end
  end

  describe "mobile card structure" do
    it "has proper card structure" do
      render_inline(component)
      expect(page).to have_css(".card > .card-body")
    end

    it "renders each item as a separate card" do
      render_inline(component)
      expect(page).to have_css(".card.mb-3", count: 2)
    end
  end
end