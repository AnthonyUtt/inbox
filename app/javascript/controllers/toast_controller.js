import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => this.dismiss(), 3000)
  }

  dismiss() {
    this.element.classList.add("toast--fade-out")
    this.element.addEventListener("animationend", () => this.element.remove())
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }
}
