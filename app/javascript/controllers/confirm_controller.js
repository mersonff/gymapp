import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="confirm"
export default class extends Controller {
  static values = { 
    message: String,
    title: { type: String, default: "Confirmar ação" },
    confirmText: { type: String, default: "Confirmar" },
    cancelText: { type: String, default: "Cancelar" }
  }

  confirm(event) {
    event.preventDefault()
    
    const message = this.messageValue || "Tem certeza que deseja continuar?"
    
    this.showConfirmDialog(message).then((confirmed) => {
      if (confirmed) {
        // If it's a form, submit it
        if (this.element.tagName === 'FORM') {
          this.element.submit()
        }
        // If it's a link, follow it
        else if (this.element.tagName === 'A') {
          Turbo.visit(this.element.href, { action: "replace" })
        }
        // If it has a data-url, visit that
        else if (this.element.dataset.url) {
          Turbo.visit(this.element.dataset.url, { action: "replace" })
        }
      }
    })
  }

  showConfirmDialog(message) {
    return new Promise((resolve) => {
      const dialog = document.createElement('dialog')
      dialog.className = "backdrop:bg-gray-900/50 bg-white rounded-xl shadow-2xl border border-gray-200 p-6 max-w-md fixed inset-0 m-auto z-50"
      
      dialog.innerHTML = `
        <div class="text-center">
          <div class="mx-auto w-12 h-12 bg-amber-100 rounded-full flex items-center justify-center mb-4">
            <svg class="w-6 h-6 text-amber-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
          </div>
          <h3 class="text-lg font-semibold text-gray-900 mb-2">${this.titleValue}</h3>
          <p class="text-gray-600 mb-6">${message}</p>
          <div class="flex space-x-3">
            <button class="cancel-btn flex-1 px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">
              ${this.cancelTextValue}
            </button>
            <button class="confirm-btn flex-1 px-4 py-2 text-sm font-medium text-white bg-red-600 hover:bg-red-700 rounded-lg transition-colors">
              ${this.confirmTextValue}
            </button>
          </div>
        </div>
      `
      
      document.body.appendChild(dialog)
      dialog.showModal()
      
      const cleanup = () => {
        document.body.removeChild(dialog)
      }
      
      dialog.querySelector('.cancel-btn').addEventListener('click', () => {
        dialog.close()
        cleanup()
        resolve(false)
      })
      
      dialog.querySelector('.confirm-btn').addEventListener('click', () => {
        dialog.close()
        cleanup()
        resolve(true)
      })
      
      dialog.addEventListener('click', (event) => {
        if (event.target === dialog) {
          dialog.close()
          cleanup()
          resolve(false)
        }
      })
      
      // Focus the confirm button by default
      setTimeout(() => {
        dialog.querySelector('.confirm-btn').focus()
      }, 100)
    })
  }
}
