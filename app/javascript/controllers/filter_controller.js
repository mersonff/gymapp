import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filter"
export default class extends Controller {
  static targets = ["form", "results"]
  static values = { url: String }

  connect() {
    // Only add event listener if form target exists
    if (this.hasFormTarget) {
      this.formTarget.addEventListener("change", this.filter.bind(this))
    }
  }

  async filter(event) {
    if (event) {
      event.preventDefault()
    }
    
    if (!this.hasFormTarget) {
      console.warn("Filter controller: form target not found")
      return
    }
    
    const formData = new FormData(this.formTarget)
    const params = new URLSearchParams(formData)
    
    try {
      const response = await fetch(`${this.urlValue}?${params}`, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })
      
      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Filter request failed:", error)
    }
  }

  clear() {
    if (this.hasFormTarget) {
      this.formTarget.reset()
      this.filter({ preventDefault: () => {} })
    }
  }
}
