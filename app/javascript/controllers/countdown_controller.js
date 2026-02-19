import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { endsAt: String }
  static targets = ["display"]

  connect() {
    this.update()
    this.interval = setInterval(() => this.update(), 1000)
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }

  update() {
    const endsAt = new Date(this.endsAtValue)
    const remaining = Math.max(0, Math.ceil((endsAt - Date.now()) / 1000))

    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = `${remaining}s`
    }

    if (remaining <= 0) {
      clearInterval(this.interval)
      this.element.remove()
    }
  }
}
