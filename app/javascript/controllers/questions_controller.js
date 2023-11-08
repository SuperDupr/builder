import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["aiPromptAttached", "aiPrompt"]

  connect() {
    // Instead of hiding the whole component you have to make the text of p tag blurry
    // this.aiPromptAttachedTarget.style.display = "none"

    const aiPromptAttachedCheckBox = document.getElementById("question_ai_prompt_attached")

    if (!aiPromptAttachedCheckBox.checked) {
      this.aiPromptTarget.style.display = "none"
    }
  }

  toggleAiPromptContainerView(e) {
    if (e.target.checked) {
      this.aiPromptTarget.style.display = "block"
    } else {
      this.aiPromptTarget.style.display = "none"
    }
  }


}