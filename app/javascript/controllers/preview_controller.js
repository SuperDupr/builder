import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["inputPreText", "outputPreText", "inputPostText", "outputPostText"];

  connect() {
    this.updatePreTextOutput();
    this.updatePostTextOutput();
  }

  updatePreTextOutput() {
    this.outputPreTextTarget.textContent = this.inputPreTextTarget.value;
  }
  updatePostTextOutput() {
    this.outputPostTextTarget.textContent = this.inputPostTextTarget.value;
  }
}
