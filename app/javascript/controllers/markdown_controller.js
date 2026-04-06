import { Controller } from "@hotwired/stimulus"

const LIST_PREFIX = /^(\s*)([-*+]|\d+\.)\s/
const ORDERED_NUM = /^(\s*)(\d+)\.\s/

export default class extends Controller {
  static targets = ["textarea"]

  handleKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey && !event.metaKey && !event.ctrlKey) {
      this.handleEnter(event)
    } else if (event.key === "Tab") {
      this.handleTab(event)
    }
  }

  handleEnter(event) {
    const textarea = this.textareaTarget
    const { selectionStart, selectionEnd, value } = textarea

    // Only act when cursor is a caret (no selection)
    if (selectionStart !== selectionEnd) return

    const lineStart = value.lastIndexOf("\n", selectionStart - 1) + 1
    const currentLine = value.substring(lineStart, selectionStart)
    const match = currentLine.match(LIST_PREFIX)

    if (!match) return

    const [fullPrefix, indent, bullet] = match
    const content = currentLine.substring(fullPrefix.length)

    event.preventDefault()

    if (content.length === 0) {
      // Empty list item — remove prefix and end the list
      textarea.setSelectionRange(lineStart, selectionStart)
      this.insertText(textarea, "\n")
    } else {
      // Continue the list
      const nextPrefix = this.nextPrefix(indent, bullet)
      this.insertText(textarea, "\n" + nextPrefix)
    }
  }

  handleTab(event) {
    const textarea = this.textareaTarget
    const { selectionStart, value } = textarea

    event.preventDefault()

    const lineStart = value.lastIndexOf("\n", selectionStart - 1) + 1
    const lineEnd = value.indexOf("\n", selectionStart)
    const lineEndPos = lineEnd === -1 ? value.length : lineEnd

    if (event.shiftKey) {
      // Outdent: remove up to 2 leading spaces
      const line = value.substring(lineStart, lineEndPos)
      const spacesToRemove = line.startsWith("  ") ? 2 : line.startsWith(" ") ? 1 : 0
      if (spacesToRemove > 0) {
        textarea.setSelectionRange(lineStart, lineStart + spacesToRemove)
        this.insertText(textarea, "")
      }
    } else {
      // Indent: add 2 spaces at line start
      const cursorOffset = selectionStart - lineStart
      textarea.setSelectionRange(lineStart, lineStart)
      this.insertText(textarea, "  ")
      textarea.setSelectionRange(lineStart + cursorOffset + 2, lineStart + cursorOffset + 2)
    }
  }

  nextPrefix(indent, bullet) {
    const orderedMatch = bullet.match(/^(\d+)\.$/)
    if (orderedMatch) {
      return `${indent}${parseInt(orderedMatch[1]) + 1}. `
    }
    return `${indent}${bullet} `
  }

  insertText(textarea, text) {
    // Use execCommand for undo support, fall back to setRangeText
    textarea.focus()
    if (!document.execCommand("insertText", false, text)) {
      const start = textarea.selectionStart
      textarea.setRangeText(text, start, textarea.selectionEnd, "end")
      textarea.dispatchEvent(new Event("input", { bubbles: true }))
    }
  }
}
