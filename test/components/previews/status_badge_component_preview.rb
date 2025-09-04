# frozen_string_literal: true

class StatusBadgeComponentPreview < ViewComponent::Preview
  # @label Pending
  def pending
    render(StatusBadgeComponent.new(status: "pending"))
  end

  # @label Completed
  def completed
    render(StatusBadgeComponent.new(status: "completed"))
  end
end
