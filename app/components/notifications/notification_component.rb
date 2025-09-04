# frozen_string_literal: true

class Notifications::NotificationComponent < ViewComponent::Base
  def initialize(message:, type: :info, dismissible: true, duration: 5000, css_class: "")
    @message = message
    @type = type
    @dismissible = dismissible
    @duration = duration
    @css_class = css_class
  end

  private

  attr_reader :message, :type, :dismissible, :duration, :css_class

  def alert_classes
    base_classes = "alert alert-#{bootstrap_type} alert-dismissible fade show"
    base_classes += " #{css_class}" if css_class.present?
    base_classes
  end

  def bootstrap_type
    case type
    when :success
      "success"
    when :error, :danger
      "danger"
    when :warning
      "warning"
    when :info
      "info"
    else
      "info"
    end
  end

  def icon_class
    case type
    when :success
      "fa-check-circle"
    when :error, :danger
      "fa-exclamation-circle"
    when :warning
      "fa-exclamation-triangle"
    when :info
      "fa-info-circle"
    else
      "fa-info-circle"
    end
  end
end
