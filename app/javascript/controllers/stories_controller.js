import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  connect() {
    this.csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  }

  showQuestionsAbsenceAlert() {
    alert("Your chosen story builder has no associated questions!")
  }

  updateStoryAccessOrDraftMode(event) {
    const storyId = event.target.dataset.id
    let privateAccess = document.getElementById(`privateAccess${storyId}`);
    const accountId = event.target.dataset.accountId
    let changeAccessMode = event.target.dataset.changeAccessMode
    let draftMode = event.target.dataset.draftMode
    
    fetch(`/accounts/${accountId}/stories/${storyId}?change_access_mode=${changeAccessMode}&draft_mode=${draftMode}`, { 
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken
      },
    }).then((response) => {
      if (response.ok) {
        response.json().then((data) => {
          let operationResultInfo

          if (data.operation === "change_access_mode") {
            operationResultInfo = data.private_access ? "Private" : "Public"
            privateAccess.textContent = operationResultInfo
          } else if (data.operation === "draft_mode") {
            operationResultInfo = data.status
            alert(`Story saved as ${operationResultInfo} successfully!`)
          }
        })
      }
    })
  }

  generateFinalVersion() {
    let finalStoryContainer = document.getElementById("finalStoryContainer")
    let accountId = finalStoryContainer.dataset.accountId
    let storyId = finalStoryContainer.dataset.storyId
    let spinner = document.querySelector(".spinnerStory")

    spinner.style.display = "flex"

    fetch(`/accounts/${accountId}/stories/${storyId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken
      }
    })
    .then(response => response.json())
    .then(data => {
      console.log("Work under process!")
    })
  }

  toggleStoryVisibility(event) {
    const storyId = event.target.dataset.id
    const viewableTextContainer = document.getElementById(`viewableTextContainer${storyId}`)
    
    fetch(`/stories/${storyId}/update_visibility`, { 
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken
      },
    }).then((response) => {
      if (response.ok) {
        response.json().then((data) => {
          if (data.success) {
            viewableTextContainer.textContent = data.viewable ? "Viewable" : "Non-viewable"
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
