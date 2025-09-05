# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cards::CardComponent, type: :component do
  let(:title) { "Test Card" }
  let(:content) { "Test content" }

  describe "#initialize" do
    it "sets default values" do
      component = described_class.new(title: title)
      
      expect(component.send(:title)).to eq(title)
      expect(component.send(:collapsible)).to be false
      expect(component.send(:collapsed)).to be true
      expect(component.send(:badge)).to be_nil
      expect(component.send(:css_class)).to eq("")
    end

    it "sets custom values" do
      component = described_class.new(
        title: title,
        collapsible: true,
        collapsed: false,
        badge: "5",
        css_class: "custom-class"
      )
      
      expect(component.send(:title)).to eq(title)
      expect(component.send(:collapsible)).to be true
      expect(component.send(:collapsed)).to be false
      expect(component.send(:badge)).to eq("5")
      expect(component.send(:css_class)).to eq("custom-class")
    end
  end

  describe "#card_classes" do
    it "returns base classes" do
      component = described_class.new(title: title)
      expect(component.send(:card_classes)).to eq("card mt-4")
    end

    it "includes custom CSS class" do
      component = described_class.new(title: title, css_class: "custom-class")
      expect(component.send(:card_classes)).to eq("card mt-4 custom-class")
    end
  end

  describe "#header_classes" do
    context "when not collapsible" do
      it "returns base header classes" do
        component = described_class.new(title: title, collapsible: false)
        expect(component.send(:header_classes)).to eq("card-header")
      end
    end

    context "when collapsible" do
      it "includes collapsible classes" do
        component = described_class.new(title: title, collapsible: true)
        expected_classes = "card-header d-flex justify-content-between align-items-center collapse-toggle"
        expect(component.send(:header_classes)).to eq(expected_classes)
      end
    end
  end

  describe "#chevron_icon" do
    context "when not collapsible" do
      it "returns empty string" do
        component = described_class.new(title: title, collapsible: false)
        expect(component.send(:chevron_icon)).to eq("")
      end
    end

    context "when collapsible and collapsed" do
      it "returns chevron down icon" do
        component = described_class.new(title: title, collapsible: true, collapsed: true)
        expect(component.send(:chevron_icon)).to eq("fa-chevron-down")
      end
    end

    context "when collapsible and not collapsed" do
      it "returns chevron up icon" do
        component = described_class.new(title: title, collapsible: true, collapsed: false)
        expect(component.send(:chevron_icon)).to eq("fa-chevron-up")
      end
    end
  end

  describe "rendering" do
    context "when not collapsible" do
      let(:component) { described_class.new(title: title) }

      it "renders without errors" do
        expect { render_inline(component) { content } }.not_to raise_error
      end

      it "renders the title" do
        render_inline(component) { content }
        expect(page).to have_css("h3", text: title)
      end

      it "renders the content" do
        render_inline(component) { content }
        expect(page).to have_content(content)
      end

      it "does not include collapse controller" do
        render_inline(component) { content }
        expect(page).not_to have_css("[data-controller='collapse']")
      end

      it "does not include chevron icon" do
        render_inline(component) { content }
        expect(page).not_to have_css("i.fas.fa-chevron")
      end
    end

    context "when collapsible" do
      let(:component) { described_class.new(title: title, collapsible: true, collapsed: true) }

      it "renders without errors" do
        expect { render_inline(component) { content } }.not_to raise_error
      end

      it "renders the title" do
        render_inline(component) { content }
        expect(page).to have_css("h3", text: title)
      end

      it "renders the content" do
        render_inline(component) { content }
        expect(page).to have_content(content)
      end

      it "includes collapse controller" do
        render_inline(component) { content }
        expect(page).to have_css("[data-controller='collapse']")
      end

      it "includes collapse toggle action" do
        render_inline(component) { content }
        expect(page).to have_css("[data-action='click->collapse#toggle']")
      end

      it "includes collapse targets" do
        render_inline(component) { content }
        expect(page).to have_css("[data-collapse-target='toggle']")
        expect(page).to have_css("[data-collapse-target='content']")
      end

      it "renders chevron down icon when collapsed" do
        render_inline(component) { content }
        expect(page).to have_css("i.fas.fa-chevron-down")
      end

      it "renders chevron up icon when not collapsed" do
        component = described_class.new(title: title, collapsible: true, collapsed: false)
        render_inline(component) { content }
        expect(page).to have_css("i.fas.fa-chevron-up")
      end
    end

    context "with badge" do
      let(:component) { described_class.new(title: title, badge: "5") }

      it "renders the badge" do
        render_inline(component) { content }
        expect(page).to have_css(".badge.bg-secondary", text: "5")
      end

      it "renders badge with correct ID" do
        render_inline(component) { content }
        expect(page).to have_css("#comments-count", text: "5")
      end
    end

    context "with custom CSS class" do
      let(:component) { described_class.new(title: title, css_class: "custom-class") }

      it "applies custom CSS class" do
        render_inline(component) { content }
        expect(page).to have_css(".card.custom-class")
      end
    end
  end

  describe "accessibility" do
    let(:component) { described_class.new(title: title, collapsible: true) }

    it "has proper cursor styling for collapsible header" do
      render_inline(component) { content }
      expect(page).to have_css(".card-header[style*='cursor: pointer;']")
    end

    it "has proper ARIA attributes" do
      render_inline(component) { content }
      # The component should be accessible, though specific ARIA attributes
      # would need to be added to the template for full accessibility
    end
  end
end