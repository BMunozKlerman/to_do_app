module ApplicationHelper
  def show_notification(message, type: :info, dismissible: true, duration: 5000, css_class: "")
    render Notifications::NotificationComponent.new(
      message: message,
      type: type,
      dismissible: dismissible,
      duration: duration,
      css_class: css_class
    )
  end
end
