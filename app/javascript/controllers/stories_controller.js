import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  connect() {
    this.index = 0
  }

  updateStoryAccessOrDraftMode(event) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    const accountId = event.target.dataset.accountId
    const storyId = event.target.dataset.id
    let changeAccessMode = event.target.dataset.changeAccessMode
    let draftMode = event.target.dataset.draftMode
    
    fetch(`/accounts/${accountId}/stories/${storyId}?change_access_mode=${changeAccessMode}&draft_mode=${draftMode}`, { 
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
    }).then((response) => {
      if (response.ok) {
        response.json().then((data) => {
          let operationResultInfo

          if (data.operation === "change_access_mode") {
            operationResultInfo = data.private_access ? "Private" : "Public"
            alert(`Story marked as ${operationResultInfo}!`)
            // TODO: Add a redirect to stories index page
          } else if (data.operation === "draft_mode") {
            operationResultInfo = data.status
            alert(`Story saved as ${operationResultInfo} successfully!`)
          }
        })
      }
    })
  }

  promptNavigation(event) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    let promptNumber = document.getElementById("promptNumber")
    let promptContainer = document.getElementById("promptContainer")
    let questionId = document.getElementById("questionContainer").dataset.id
    let cursor = event.target.dataset.cursor
    
    // TODO: Add validations to handle index value correctly
    if (cursor == "backward") {
      this.index--
    } else if (cursor == "forward") {
      this.index++
    }

    fetch(`/question/${questionId}/prompts?index=${this.index}`, { 
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      }
    }).then((response) => {
      if (response.ok) {
        response.json().then((data) => {
          if (data.success) {
            promptNumber.textContent = this.index + 1
            promptContainer.dataset.id = data.prompt_id
            promptContainer.textContent = data.prompt_sentence
          }
        })
      }
    })
  }
  
  reconnect(event) {
    if (consumer.connection.isActive()) {
      consumer.connection.reopen()
    }
  }
}