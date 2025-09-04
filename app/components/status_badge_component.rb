# frozen_string_literal: true

class StatusBadgeComponent < ViewComponent::Base
  def initialize(status:)
    @status = status
  end

  private

  def badge_class
    case @status
    when "completed"
      "bg-success"
    else
      "bg-warning"
    end
  end

  def status_text
    @status.humanize
  end
end
