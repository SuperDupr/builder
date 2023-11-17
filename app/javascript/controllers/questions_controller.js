import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["aiPromptAttached", "aiPrompt", "aiPromptTextarea"]

  connect() {
    // Instead of hiding the whole component you have to make the text of p tag blurry
    // this.aiPromptAttachedTarget.style.display = "none"

    const aiPromptAttachedCheckBox = document.getElementById("question_ai_prompt_attached")

    if (!aiPromptAttachedCheckBox.checked) {
      this.aiPromptTarget.style.display = "none"
    }
    else{
      this.aiPromptTextareaTarget.required = true
    }
  }

  toggleAiPromptContainerView(e) {
    const aiPromptLabel = document.getElementById("aiPromptLabel")
    if (e.target.checked) {
      aiPromptLabel.classList.remove('opacity-50')
      this.aiPromptTarget.style.display = "block"
      this.aiPromptTextareaTarget.required = true
    } else {
      aiPromptLabel.classList.add('opacity-50')
      this.aiPromptTarget.style.display = "none"
      this.aiPromptTextareaTarget.required = false
    }
  }


}