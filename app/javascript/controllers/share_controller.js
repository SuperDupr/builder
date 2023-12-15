import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static targets = ["shareInputField", "select"];
  connect() {
    this.csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    this.selectSearch()
  }
  

  selectSearch() {
    const inputField = this.shareInputFieldTarget
    this.select = new TomSelect(this.selectTarget, {
      plugins: ['remove_button'],
      onChange:function(){
        inputField.value = this.items.toString()
      },
    })
  }

  disconnect() {
    this.select.destroy()
  }
}
