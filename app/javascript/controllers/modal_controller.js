import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["modal"]

  connect() {
    console.log("Modal controller connected")
    // Auto-focus first input when modal opens
    this.focusFirstInput()
    // Ensure modal is showing
    if (this.hasModalTarget && !this.modalTarget.open) {
      this.modalTarget.showModal()
    }
  }

  open() {
    this.modalTarget.showModal()
    this.focusFirstInput()
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.modalTarget.close()
    document.body.classList.remove("overflow-hidden")
    // Remove the turbo frame content after closing
    setTimeout(() => {
      const modalFrame = document.getElementById("modal_frame")
      if (modalFrame) {
        modalFrame.innerHTML = ""
      }
    }, 200)
  }

  // Close modal when clicking outside
  clickOutside(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  // Close modal on Escape key
  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  focusFirstInput() {
    const firstInput = this.modalTarget.querySelector('input, textarea, select')
    if (firstInput) {
      setTimeout(() => firstInput.focus(), 100)
    }
  }
}
