// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"
import "trix"
import "@rails/actiontext"

// Verificar se Turbo está carregado
console.log("Turbo carregado?", typeof Turbo !== 'undefined')
if (typeof Turbo !== 'undefined') {
  console.log("Turbo version:", Turbo.session.version)
}

// Configure Turbo
Turbo.config.drive.progressBarDelay = 500

// Forçar todos os formulários a usar Turbo Stream
document.addEventListener("turbo:before-fetch-request", (event) => {
  const { fetchOptions } = event.detail
  if (fetchOptions.method === "POST" || fetchOptions.method === "PATCH" || fetchOptions.method === "PUT") {
    fetchOptions.headers["Accept"] = "text/vnd.turbo-stream.html, text/html, application/xhtml+xml"
    console.log("Forçando Accept header para:", fetchOptions.headers["Accept"])
  }
})

// Debug form submissions
document.addEventListener("turbo:submit-start", (event) => {
  console.log("=== FORM SUBMIT START ===")
  console.log("Form:", event.target)
  
  // Forçar turbo-stream para forms com data-turbo-stream
  if (event.target.dataset.turboStream === "true") {
    console.log("Forçando formato turbo-stream")
    const submission = event.detail.formSubmission
    submission.fetchRequest.headers["Accept"] = "text/vnd.turbo-stream.html, text/html, application/xhtml+xml"
  }
  
  console.log("Accept header será:", event.detail.formSubmission.fetchRequest.headers)
})

// Loading indicator
document.addEventListener('turbo:before-fetch-request', () => {
  const progressBar = document.getElementById('turbo-progress-bar')
  if (progressBar) {
    progressBar.style.width = '30%'
  }
})

document.addEventListener('turbo:before-stream-render', () => {
  const progressBar = document.getElementById('turbo-progress-bar')
  if (progressBar) {
    progressBar.style.width = '60%'
  }
})

document.addEventListener('turbo:render', () => {
  const progressBar = document.getElementById('turbo-progress-bar')
  if (progressBar) {
    progressBar.style.width = '100%'
    setTimeout(() => {
      progressBar.style.width = '0%'
    }, 200)
  }
})

// Handle form submissions
document.addEventListener('turbo:submit-start', (event) => {
  const form = event.target
  const submitButton = form.querySelector('input[type="submit"], button[type="submit"]')
  if (submitButton) {
    submitButton.disabled = true
    const originalText = submitButton.textContent || submitButton.value
    submitButton.dataset.originalText = originalText
    submitButton.innerHTML = `
      <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white inline" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      Processando...
    `
  }
})

document.addEventListener('turbo:submit-end', (event) => {
  const form = event.target
  const submitButton = form.querySelector('input[type="submit"], button[type="submit"]')
  if (submitButton) {
    submitButton.disabled = false
    const originalText = submitButton.dataset.originalText
    if (originalText) {
      submitButton.textContent = originalText
    }
  }
})

// Auto-close modals on successful form submission
document.addEventListener('turbo:before-stream-render', (event) => {
  const fallbackToHTMLRedirect = event.detail.render === undefined
  if (!fallbackToHTMLRedirect) {
    // Check if we need to close any open modals
    const openModals = document.querySelectorAll('dialog[open]')
    openModals.forEach(modal => {
      if (modal.id.includes('modal')) {
        modal.close()
      }
    })
  }
})

// Enhanced confirmation dialog
Turbo.config.forms.confirm = (message, element) => {
  return new Promise((resolve) => {
    const dialog = document.createElement('dialog')
    dialog.className = "backdrop:bg-gray-900/50 bg-white rounded-2xl shadow-2xl border border-gray-200 p-6 max-w-md fixed inset-0 m-auto z-50"
    dialog.innerHTML = `
      <form method="dialog">
        <div class="text-center mb-6">
          <div class="mx-auto w-12 h-12 bg-red-100 rounded-full flex items-center justify-center mb-4">
            <svg class="w-6 h-6 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
          </div>
          <p class="text-lg font-medium text-gray-900">Confirmar ação</p>
          <p class="text-sm text-gray-600 mt-2">${message}</p>
        </div>
        <div class="flex space-x-3">
          <button type="button" value="false" class="flex-1 px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">
            Cancelar
          </button>
          <button type="button" value="true" class="flex-1 px-4 py-2 text-sm font-medium text-white bg-red-600 hover:bg-red-700 rounded-lg transition-colors">
            Confirmar
          </button>
        </div>
      </form>
    `
    
    document.body.appendChild(dialog)
    dialog.showModal()
    
    dialog.addEventListener('close', () => {
      const result = dialog.returnValue === 'true'
      document.body.removeChild(dialog)
      resolve(result)
    }, { once: true })
    
    dialog.addEventListener('click', (event) => {
      if (event.target === dialog) {
        dialog.close('false')
      }
    })
    
    const buttons = dialog.querySelectorAll('button')
    buttons.forEach(button => {
      button.addEventListener('click', () => {
        dialog.close(button.value)
      })
    })
  })
}

// Debug logging and visual indicators
document.addEventListener("turbo:before-fetch-request", (event) => {
  console.log("🚀 Turbo: Fazendo requisição", event.detail)
})

document.addEventListener("turbo:before-stream-render", (event) => {
  console.log("⚡ Turbo Stream: Atualizando página", event.detail)
})

document.addEventListener("turbo:load", () => {
  console.log("✅ Turbo: Página carregada via Hotwire")
})

document.addEventListener("turbo:render", () => {
  console.log("🎨 Turbo: Renderizando com Hotwire")
})

// Indicador visual de que Hotwire está ativo
document.addEventListener("DOMContentLoaded", () => {
  console.log("%c🔥 Hotwire está ATIVO!", "color: #10b981; font-size: 16px; font-weight: bold")
  console.log("Turbo version:", Turbo.session.version)
})
