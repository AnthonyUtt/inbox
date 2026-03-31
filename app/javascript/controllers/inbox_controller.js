import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea"]

  connect() {
    this.focusTextarea()
  }

  // Re-focus after Turbo Stream replaces the form
  textareaTargetConnected() {
    this.focusTextarea()
  }

  focusTextarea() {
    if (this.hasTextareaTarget) {
      this.textareaTarget.focus()
    }
  }
}
