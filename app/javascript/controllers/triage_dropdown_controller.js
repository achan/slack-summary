import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.closeHandler = this.closeOnClickOutside.bind(this)
    this.keyHandler = this.closeOnEscape.bind(this)
  }

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    const button = this.element.querySelector("button")
    const rect = button.getBoundingClientRect()
    const menu = this.menuTarget

    menu.style.position = "fixed"
    menu.style.left = `${rect.left}px`
    menu.style.bottom = `${window.innerHeight - rect.top + 4}px`
    menu.style.top = "auto"

    menu.classList.remove("hidden")
    document.addEventListener("click", this.closeHandler)
    document.addEventListener("keydown", this.keyHandler)
  }

  close() {
    this.menuTarget.classList.add("hidden")
    document.removeEventListener("click", this.closeHandler)
    document.removeEventListener("keydown", this.keyHandler)
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.closeHandler)
    document.removeEventListener("keydown", this.keyHandler)
  }
}
