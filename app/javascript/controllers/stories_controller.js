import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  connect() {
    // console.log("I am connected!")
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
  
  reconnect(event) {
    if (consumer.connection.isActive()) {
      consumer.connection.reopen()
    }
  }
}