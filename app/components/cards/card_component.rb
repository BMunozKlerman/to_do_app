# frozen_string_literal: true

class Cards::CardComponent < ViewComponent::Base
  def initialize(title:, collapsible: false, collapsed: true, badge: nil, css_class: "")
    @title = title
    @collapsible = collapsible
    @collapsed = collapsed
    @badge = badge
    @css_class = css_class
  end

  private

  attr_reader :title, :collapsible, :collapsed, :badge, :css_class

  def card_classes
    base_classes = "card mt-4"
    base_classes += " #{css_class}" if css_class.present?
    base_classes
  end

  def header_classes
    base_classes = "card-header"
    if collapsible
      base_classes += " d-flex justify-content-between align-items-center"
      base_classes += " collapse-toggle" # Add a class for styling
    end
    base_classes
  end


  def chevron_icon
    if collapsible
      if collapsed
        "fa-chevron-down"
      else
        "fa-chevron-up"
      end
    else
      ""
    end
  end
end
