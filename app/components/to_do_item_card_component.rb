# frozen_string_literal: true

class ToDoItemCardComponent < ViewComponent::Base
  def initialize(todo_item:)
    @todo_item = todo_item
  end

  private

  def card_class
    base_class = "card mb-3"
    base_class += " border-warning" if @todo_item.overdue?
    base_class
  end

  def overdue_badge
    return unless @todo_item.overdue?

    content_tag(:span, "Overdue", class: "badge bg-danger ms-2")
  end
end
