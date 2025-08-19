import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = ["submit"]

  connect() {
    this.originalText = this.submitTarget.textContent
    console.log("Form controller conectado")
    
    // Forçar Accept header para turbo-stream
    this.element.addEventListener("turbo:submit-start", (event) => {
      console.log("Configurando Accept header para turbo-stream")
      const submission = event.detail.formSubmission
      submission.fetchRequest.headers["Accept"] = "text/vnd.turbo-stream.html, text/html"
    })
  }

  submitStart() {
    this.submitTarget.disabled = true
    this.submitTarget.innerHTML = `
      <svg class="animate-spin -ml-1 mr-3 h-4 w-4 text-white inline" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      Processando...
    `
  }

  submitEnd() {
    this.submitTarget.disabled = false
    this.submitTarget.textContent = this.originalText
  }

  // Reset form after successful submission
  reset() {
    this.element.reset()
    this.submitEnd()
  }
}
