import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
  static values = { 
    duration: { type: Number, default: 5000 },
    autoDismiss: { type: Boolean, default: true }
  }

  connect() {
    if (this.autoDismissValue) {
      this.dismiss()
    }
    
    // Animate in
    this.element.classList.add("animate-slide-in")
  }

  dismiss() {
    setTimeout(() => {
      this.hide()
    }, this.durationValue)
  }

  hide() {
    this.element.classList.add("animate-slide-out")
    
    setTimeout(() => {
      if (this.element.parentNode) {
        this.element.remove()
      }
    }, 300)
  }

  close() {
    this.hide()
  }
}
