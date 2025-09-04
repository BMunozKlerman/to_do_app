import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notification"
export default class extends Controller {
  static values = { duration: Number, dismissible: Boolean }

  connect() {
    // Auto-dismiss after the specified duration
    if (this.durationValue > 0) {
      this.timeoutId = setTimeout(() => {
        this.close()
      }, this.durationValue)
    }
  }

  disconnect() {
    // Clear timeout if component is removed before auto-dismiss
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }
  }

  close() {
    // Add fade out animation
    this.element.classList.remove('show')
    this.element.classList.add('fade')
    
    // Remove from DOM after animation
    setTimeout(() => {
      this.element.remove()
    }, 150) // Bootstrap fade duration
  }
}
