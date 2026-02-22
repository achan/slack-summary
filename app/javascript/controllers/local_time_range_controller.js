import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { start: String, end: String }

  connect() {
    const parts = []
    if (this.startValue) parts.push(this.#format(this.startValue))
    if (this.endValue) parts.push(this.#format(this.endValue))
    if (parts.length) this.element.textContent = parts.join(" — ")
  }

  #format(iso) {
    const date = new Date(iso)
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    const month = months[date.getMonth()]
    const dateNum = date.getDate()
    let hours = date.getHours()
    const minutes = date.getMinutes().toString().padStart(2, "0")
    const ampm = hours >= 12 ? "PM" : "AM"
    hours = hours % 12 || 12
    return `${month} ${dateNum}, ${hours}:${minutes} ${ampm}`
  }
}
