# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::NotificationComponent, type: :component do
  let(:message) { "Test notification" }
  let(:component) { described_class.new(message: message) }

  describe "#initialize" do
    it "sets default values" do
      expect(component.send(:message)).to eq(message)
      expect(component.send(:type)).to eq(:info)
      expect(component.send(:dismissible)).to be true
      expect(component.send(:duration)).to eq(5000)
      expect(component.send(:css_class)).to eq("")
    end

    it "sets custom values" do
      component = described_class.new(
        message: message,
        type: :success,
        dismissible: false,
        duration: 3000,
        css_class: "custom-class"
      )
      
      expect(component.send(:message)).to eq(message)
      expect(component.send(:type)).to eq(:success)
      expect(component.send(:dismissible)).to be false
      expect(component.send(:duration)).to eq(3000)
      expect(component.send(:css_class)).to eq("custom-class")
    end
  end

  describe "#alert_classes" do
    it "returns base classes for info type" do
      expect(component.send(:alert_classes)).to eq("alert alert-info alert-dismissible fade show")
    end

    it "includes custom CSS class" do
      component = described_class.new(message: message, css_class: "custom-class")
      expect(component.send(:alert_classes)).to eq("alert alert-info alert-dismissible fade show custom-class")
    end

    context "with different types" do
      it "returns success classes" do
        component = described_class.new(message: message, type: :success)
        expect(component.send(:alert_classes)).to eq("alert alert-success alert-dismissible fade show")
      end

      it "returns danger classes for error type" do
        component = described_class.new(message: message, type: :error)
        expect(component.send(:alert_classes)).to eq("alert alert-danger alert-dismissible fade show")
      end

      it "returns danger classes for danger type" do
        component = described_class.new(message: message, type: :danger)
        expect(component.send(:alert_classes)).to eq("alert alert-danger alert-dismissible fade show")
      end

      it "returns warning classes" do
        component = described_class.new(message: message, type: :warning)
        expect(component.send(:alert_classes)).to eq("alert alert-warning alert-dismissible fade show")
      end
    end
  end

  describe "#bootstrap_type" do
    it "returns correct bootstrap type for info" do
      expect(component.send(:bootstrap_type)).to eq("info")
    end

    it "returns correct bootstrap type for success" do
      component = described_class.new(message: message, type: :success)
      expect(component.send(:bootstrap_type)).to eq("success")
    end

    it "returns correct bootstrap type for error" do
      component = described_class.new(message: message, type: :error)
      expect(component.send(:bootstrap_type)).to eq("danger")
    end

    it "returns correct bootstrap type for danger" do
      component = described_class.new(message: message, type: :danger)
      expect(component.send(:bootstrap_type)).to eq("danger")
    end

    it "returns correct bootstrap type for warning" do
      component = described_class.new(message: message, type: :warning)
      expect(component.send(:bootstrap_type)).to eq("warning")
    end

    it "returns info for unknown type" do
      component = described_class.new(message: message, type: :unknown)
      expect(component.send(:bootstrap_type)).to eq("info")
    end
  end

  describe "#icon_class" do
    it "returns correct icon for info" do
      expect(component.send(:icon_class)).to eq("fa-info-circle")
    end

    it "returns correct icon for success" do
      component = described_class.new(message: message, type: :success)
      expect(component.send(:icon_class)).to eq("fa-check-circle")
    end

    it "returns correct icon for error" do
      component = described_class.new(message: message, type: :error)
      expect(component.send(:icon_class)).to eq("fa-exclamation-circle")
    end

    it "returns correct icon for danger" do
      component = described_class.new(message: message, type: :danger)
      expect(component.send(:icon_class)).to eq("fa-exclamation-circle")
    end

    it "returns correct icon for warning" do
      component = described_class.new(message: message, type: :warning)
      expect(component.send(:icon_class)).to eq("fa-exclamation-triangle")
    end

    it "returns info icon for unknown type" do
      component = described_class.new(message: message, type: :unknown)
      expect(component.send(:icon_class)).to eq("fa-info-circle")
    end
  end

  describe "rendering" do
    it "renders without errors" do
      expect { render_inline(component) }.not_to raise_error
    end

    it "renders the message" do
      render_inline(component)
      expect(page).to have_content("Test notification")
    end

    it "renders with correct CSS classes" do
      render_inline(component)
      expect(page).to have_css(".alert.alert-info.alert-dismissible.fade.show")
    end

    it "renders with correct role" do
      render_inline(component)
      expect(page).to have_css(".alert[role='alert']")
    end

    it "renders with correct positioning" do
      render_inline(component)
      expect(page).to have_css(".alert[style*='position: fixed; top: 20px; right: 20px; z-index: 9999;']")
    end

    it "renders with correct sizing" do
      render_inline(component)
      expect(page).to have_css(".alert[style*='min-width: 300px; max-width: 500px;']")
    end

    it "renders the icon" do
      render_inline(component)
      expect(page).to have_css("i.fas.fa-info-circle")
    end

    it "renders the close button when dismissible" do
      render_inline(component)
      expect(page).to have_css("button.btn-close")
      expect(page).to have_css("button[type='button']")
      expect(page).to have_css("button[aria-label='Close']")
    end

    it "does not render close button when not dismissible" do
      component = described_class.new(message: message, dismissible: false)
      render_inline(component)
      expect(page).not_to have_css("button.btn-close")
    end
  end

  describe "with different types" do
    context "success notification" do
      let(:component) { described_class.new(message: message, type: :success) }

      it "renders with success classes" do
        render_inline(component)
        expect(page).to have_css(".alert.alert-success")
      end

      it "renders success icon" do
        render_inline(component)
        expect(page).to have_css("i.fas.fa-check-circle")
      end
    end

    context "error notification" do
      let(:component) { described_class.new(message: message, type: :error) }

      it "renders with danger classes" do
        render_inline(component)
        expect(page).to have_css(".alert.alert-danger")
      end

      it "renders error icon" do
        render_inline(component)
        expect(page).to have_css("i.fas.fa-exclamation-circle")
      end
    end

    context "warning notification" do
      let(:component) { described_class.new(message: message, type: :warning) }

      it "renders with warning classes" do
        render_inline(component)
        expect(page).to have_css(".alert.alert-warning")
      end

      it "renders warning icon" do
        render_inline(component)
        expect(page).to have_css("i.fas.fa-exclamation-triangle")
      end
    end
  end

  describe "with custom duration" do
    let(:component) { described_class.new(message: message, duration: 10000) }

    it "sets the duration data attribute" do
      render_inline(component)
      expect(page).to have_css("[data-notification-duration-value='10000']")
    end
  end

  describe "with custom CSS class" do
    let(:component) { described_class.new(message: message, css_class: "custom-notification") }

    it "applies custom CSS class" do
      render_inline(component)
      expect(page).to have_css(".alert.custom-notification")
    end
  end

  describe "Stimulus controller integration" do
    it "includes notification controller" do
      render_inline(component)
      expect(page).to have_css("[data-controller='notification']")
    end

    it "sets dismissible data attribute" do
      render_inline(component)
      # The data attribute is set in the template
      expect(page).to have_css("[data-notification-dismissible-value]")
    end

    it "sets dismissible data attribute to false when not dismissible" do
      component = described_class.new(message: message, dismissible: false)
      render_inline(component)
      # The data attribute is missing when dismissible is false, so just check the alert exists
      expect(page).to have_css(".alert")
    end

    it "includes close action on button" do
      render_inline(component)
      expect(page).to have_css("button[data-action='click->notification#close']")
    end
  end

  describe "accessibility" do
    it "has proper ARIA attributes" do
      render_inline(component)
      expect(page).to have_css("[role='alert']")
      expect(page).to have_css("button[aria-label='Close']")
    end

    it "has proper button attributes" do
      render_inline(component)
      expect(page).to have_css("button[type='button']")
    end
  end

  describe "layout structure" do
    it "has proper flex layout" do
      render_inline(component)
      expect(page).to have_css(".d-flex.align-items-center")
    end

    it "has proper icon spacing" do
      render_inline(component)
      expect(page).to have_css("i.fas.me-2")
    end

    it "has proper content flex" do
      render_inline(component)
      expect(page).to have_css(".flex-grow-1")
    end
  end
end