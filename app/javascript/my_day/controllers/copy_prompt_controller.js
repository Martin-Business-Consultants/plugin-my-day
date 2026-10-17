import { Controller } from "@hotwired/stimulus"

// My day's Copy for AI in the bulk bar (my-day--copy-prompt): one prompt for the picked rows,
// fetched from BriefsController with their ids, in the order they're on the page (a row shown twice
// goes once), and put on the clipboard. The fetch goes inside a ClipboardItem so Safari keeps the
// click's permission while it loads. Reads the core bulk controller's boxes; changes nothing of it.
export default class extends Controller {
  static values = { url: String }
  static classes = [ "copied" ]

  async copy(event) {
    event.preventDefault()
    const url = new URL(this.urlValue, window.location.href)
    const ids = [ ...document.querySelectorAll("[data-bulk-target~='item']:checked") ].map(box => box.value)
    new Set(ids).forEach(id => url.searchParams.append("ids[]", id))
    this.element.classList.remove(this.copiedClass)

    const text = fetch(url, { headers: { Accept: "text/plain" }, credentials: "same-origin" })
      .then(response => { if (!response.ok) throw new Error(response.statusText); return response.text() })
    try {
      if (window.ClipboardItem && navigator.clipboard.write) {
        await navigator.clipboard.write([ new ClipboardItem({ "text/plain": text.then(t => new Blob([ t ], { type: "text/plain" })) }) ])
      } else {
        await navigator.clipboard.writeText(await text)
      }
      this.element.classList.add(this.copiedClass)
    } catch {}
  }
}
