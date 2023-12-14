import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static targets = ["tagsInputField", "select"];
  connect() {
    this.creatableSelectSearch()
  }

  creatableSelectSearch() {
    const inputField = this.tagsInputFieldTarget
    this.select = new TomSelect(this.selectTarget, {
      create: true,
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
