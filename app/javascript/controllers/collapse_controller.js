import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="collapse"
export default class extends Controller {
  static targets = ["content", "toggle"]

  connect() {
    // Initialize the collapse state from localStorage or default to true
    this.isCollapsed = this.getStoredState()
    console.log("Collapse controller connected, isCollapsed:", this.isCollapsed)
    this.updateContent()
    this.updateToggle()
  }

  toggle() {
    console.log("Toggle called, current state:", this.isCollapsed)
    this.isCollapsed = !this.isCollapsed
    console.log("New state:", this.isCollapsed)
    this.storeState()
    this.updateContent()
    this.updateToggle()
  }

  updateContent() {
    if (this.hasContentTarget) {
      console.log("Updating content, isCollapsed:", this.isCollapsed)
      if (this.isCollapsed) {
        this.contentTarget.classList.add('hidden')
        console.log("Added hidden class, classes:", this.contentTarget.className)
      } else {
        this.contentTarget.classList.remove('hidden')
        console.log("Removed hidden class, classes:", this.contentTarget.className)
      }
    } else {
      console.log("No content target found")
    }
  }

  updateToggle() {
    if (this.hasToggleTarget) {
      const icon = this.toggleTarget.querySelector('i')
      if (icon) {
        if (this.isCollapsed) {
          icon.classList.remove('fa-chevron-up')
          icon.classList.add('fa-chevron-down')
        } else {
          icon.classList.remove('fa-chevron-down')
          icon.classList.add('fa-chevron-up')
        }
      }
    }
  }

  getStoredState() {
    const stored = localStorage.getItem('completedTasksCollapsed')
    return stored !== null ? stored === 'true' : true
  }

  storeState() {
    localStorage.setItem('completedTasksCollapsed', this.isCollapsed.toString())
  }
}
