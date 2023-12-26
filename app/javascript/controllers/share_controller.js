import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static targets = ["shareInputField", "select", "blogAccessAttached", "blogAccess"]

  connect() {
    this.selectSearch()

    const blogAccessAttachedCheckBox = document.getElementById("blog_public_access")

    if (!blogAccessAttachedCheckBox.checked) {
      this.blogAccessTarget.style.display = "block"
    }

    else{
      blogAccessLabel.classList.remove('opacity-50')
    }
  }

  toggleblogAccessContainerView(e) {
    const blogAccessLabel = document.getElementById("blogAccessLabel")
    if (e.target.checked) {
      blogAccessLabel.classList.remove('opacity-50')
      this.blogAccessTarget.style.display = "none"
    } else {
      blogAccessLabel.classList.add('opacity-50')
      this.blogAccessTarget.style.display = "block"
    }
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
