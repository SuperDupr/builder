import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  connect() {
    this.index = 0
    this.qIndex = 0
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
          } else {
            if (cursor == "backward") {
              this.index++
            } else if (cursor == "forward") {
              this.index--
            }
          }
        })
      }
    })
  }

  questionNavigation(event) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    let questionNumber = document.getElementById("questionNumber")
    let questionContainer = document.getElementById("questionContainer")
    let cursor = event.target.dataset.cursor
    let storyBuilderId = event.target.dataset.storyBuilderId
    
    // TODO: Add validations to handle index value correctly
    if (cursor == "backward") {
      this.qIndex--
    } else if (cursor == "forward") {
      this.qIndex++
    }

    fetch(`/stories/${storyBuilderId}/questions?q_index=${this.qIndex}`, { 
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      }
    }).then((response) => {
      if (response.ok) {
        response.json().then((data) => {
          if (data.success) {
            questionNumber.textContent = this.qIndex + 1
            questionContainer.dataset.id = data.question_id
            questionContainer.textContent = data.question_title

            // TODO: When a new question is fetched, we have to refresh prompts as well
          } else {
            if (cursor == "backward") {
              this.qIndex++
            } else if (cursor == "forward") {
              this.qIndex--
            }
          }
        })
      }
    })
  }

  // Request to track answer of a question
  
  // const questionId = 123; // Replace with the actual question ID
  // const storyId = 456; // Replace with the actual story ID
  // const responseText = "Some response text"; // Replace with the actual response text

  // const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  // fetch(`/questions/${questionId}/track_answers`, {
  //   method: "POST",
  //   headers: {
  //     "Content-Type": "application/json",
  //     "X-CSRF-Token": csrfToken
  //   },
  //   body: JSON.stringify({
  //     story_id: storyId,
  //     response: responseText
  //   })
  // })
  //   .then(response => response.json())
  //   .then(data => {
  //     if (data.success) {
  //       console.log("Answer saved successfully:", data.answer);
  //     } else {
  //       console.error("Failed to save answer:", data.answer);
  //     }
  //   })
  //   .catch(error => {
  //     console.error("Error while saving answer:", error);
  //   });

  
  reconnect(event) {
    if (consumer.connection.isActive()) {
      consumer.connection.reopen()
    }
  }
}