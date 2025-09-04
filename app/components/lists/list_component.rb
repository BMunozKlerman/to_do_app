# frozen_string_literal: true

class Lists::ListComponent < ViewComponent::Base
  def initialize(items:, headers: nil, css_class: "", table_class: "")
    @items = items
    @headers = headers || default_headers
    @css_class = css_class
    @table_class = table_class
  end

  private

  attr_reader :title, :items, :headers, :css_class, :table_class

  def default_headers
    [
      { text: "", width: "50" },
      { text: "Name" },
      { text: "Due Date" },
      { text: "Duration" },
      { text: "Assigned To" },
      { text: "Created By" },
      { text: "Followers" },
      { text: "Actions" }
    ]
  end

  def container_classes
    base_classes = "table-responsive dropdown-container"
    base_classes += " #{css_class}" if css_class.present?
    base_classes
  end

  def table_classes
    base_classes = "table"
    base_classes += " #{table_class}" if table_class.present?
    base_classes
  end
end
