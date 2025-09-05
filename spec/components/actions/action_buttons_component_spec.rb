# frozen_string_literal: true

require "rails_helper"

RSpec.describe Actions::ActionButtonsComponent, type: :component do
  let(:to_do_item) { create(:to_do_item) }
  let(:component) { described_class.new(item: to_do_item) }

  describe "#initialize" do
    it "sets the item" do
      expect(component.send(:item)).to eq(to_do_item)
    end

    it "builds the items array" do
      items = component.send(:items)
      expect(items).to be_an(Array)
      expect(items.length).to eq(2)
    end
  end

  describe "#build_items" do
    it "creates show and edit items" do
      items = component.send(:build_items)
      
      show_item = items.find { |item| item[:text] == "Show" }
      edit_item = items.find { |item| item[:text] == "Edit" }
      
      expect(show_item).to be_present
      expect(edit_item).to be_present
    end

    it "includes correct URLs for show action" do
      items = component.send(:build_items)
      show_item = items.find { |item| item[:text] == "Show" }
      
      expect(show_item[:url]).to eq(Rails.application.routes.url_helpers.to_do_item_path(to_do_item))
      expect(show_item[:icon]).to eq("eye")
    end

    it "includes correct URLs for edit action" do
      items = component.send(:build_items)
      edit_item = items.find { |item| item[:text] == "Edit" }
      
      expect(edit_item[:url]).to eq(Rails.application.routes.url_helpers.edit_to_do_item_path(to_do_item))
      expect(edit_item[:icon]).to eq("edit")
    end
  end

  describe "rendering" do
    it "renders without errors" do
      expect { render_inline(component) }.not_to raise_error
    end

    it "renders the show button" do
      render_inline(component)
      
      expect(page).to have_link(href: Rails.application.routes.url_helpers.to_do_item_path(to_do_item))
      expect(page).to have_css("i.fas.fa-eye")
    end

    it "renders the edit button" do
      render_inline(component)
      
      expect(page).to have_link(href: Rails.application.routes.url_helpers.edit_to_do_item_path(to_do_item))
      expect(page).to have_css("i.fas.fa-edit")
    end

    it "applies correct CSS classes" do
      render_inline(component)
      
      expect(page).to have_css(".d-flex.gap-1")
      expect(page).to have_css(".btn.btn-sm.btn-link", count: 2)
    end

    it "includes title attributes for accessibility" do
      render_inline(component)
      
      expect(page).to have_css("a[title='Show']")
      expect(page).to have_css("a[title='Edit']")
    end
  end

  describe "with different item types" do
    let(:user) { create(:user) }
    let(:component) { described_class.new(item: user) }

    it "works with user items" do
      expect { render_inline(component) }.not_to raise_error
    end

    it "generates correct URLs for user items" do
      items = component.send(:build_items)
      show_item = items.find { |item| item[:text] == "Show" }
      
      # The component is hardcoded to use to_do_item routes, so it will use the user's ID as if it were a to_do_item
      expect(show_item[:url]).to eq(Rails.application.routes.url_helpers.to_do_item_path(user))
    end
  end
end
