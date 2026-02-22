import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.submitEl = this.element.querySelector("[type=submit]")
  }

  submit() {
    if (!this.submitEl) return
    this.submitEl.disabled = true
    setTimeout(() => { this.submitEl.disabled = false }, 3000)
  }
}
