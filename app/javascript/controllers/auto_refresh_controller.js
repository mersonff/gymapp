import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-refresh"
export default class extends Controller {
  static values = { 
    interval: { type: Number, default: 30000 }, // 30 seconds default
    url: String 
  }

  connect() {
    this.startRefreshing()
  }

  disconnect() {
    this.stopRefreshing()
  }

  startRefreshing() {
    this.refreshTimer = setInterval(() => {
      this.refresh()
    }, this.intervalValue)
  }

  stopRefreshing() {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer)
    }
  }

  async refresh() {
    try {
      const response = await fetch(this.urlValue, {
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
      console.error("Auto-refresh failed:", error)
    }
  }

  // Manual refresh trigger
  refreshNow() {
    this.refresh()
  }
}
