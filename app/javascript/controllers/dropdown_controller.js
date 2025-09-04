import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Controller connected
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  toggle() {
    const isHidden = this.menuTarget.classList.contains('hidden')
    
    // Close all other dropdowns
    this.closeAllDropdowns()
    
    // Toggle current dropdown
    if (isHidden) {
      // Position the dropdown relative to the button first
      const button = this.element.querySelector('button')
      const buttonRect = button.getBoundingClientRect()
      const menu = this.menuTarget
      
      // Position the menu below and to the right of the button
      menu.style.position = 'fixed'
      menu.style.top = `${buttonRect.bottom + 8}px`
      menu.style.left = `${buttonRect.left}px` // Position to the right of the button
      menu.style.zIndex = '9999'
      
      // Remove hidden class and force display
      this.menuTarget.classList.remove('hidden')
      menu.style.setProperty('display', 'block', 'important')
      
      // Force a reflow to ensure the class removal takes effect
      this.menuTarget.offsetHeight
    } else {
      // Hide the dropdown
      this.menuTarget.classList.add('hidden')
      // Remove the inline display style so the hidden class can work
      this.menuTarget.style.removeProperty('display')
    }
  }

  close() {
    this.menuTarget.classList.add('hidden')
    this.menuTarget.style.removeProperty('display')
  }

  closeAllDropdowns() {
    // Close all dropdown menus on the page except the current one
    document.querySelectorAll('[data-dropdown-target="menu"]').forEach(menu => {
      if (menu !== this.menuTarget) {
        menu.classList.add('hidden')
      }
    })
  }

  // Close dropdown when clicking outside
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}
