import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["inputPreText", "outputPreText", "inputPostText", "outputPostText"];

  connect() {
    if(this.inputPreTextTarget.value){
      this.updatePreTextOutput();
    }
    if(this.inputPostTextTarget.value){
      this.updatePostTextOutput();
    }
  }

  updatePreTextOutput() {
    this.outputPreTextTarget.textContent = this.inputPreTextTarget.value;
  }
  updatePostTextOutput() {
    this.outputPostTextTarget.textContent = this.inputPostTextTarget.value;
  }
}
