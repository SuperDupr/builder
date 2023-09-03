import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  connect() {
    this.index = 0
    this.qIndex = 0
  }

  showQuestionsAbsenceAlert() {
    alert("Your chosen story builder has no associated questions!")
  }

  updateStoryAccessOrDraftMode(event) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    let privateAccess = document.getElementById("privateAccess");
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
            privateAccess.textContent = operationResultInfo
            // TODO: Add a redirect to stories index page
          // } else if (data.operation === "draft_mode") {
          //   // operationResultInfo = data.status
          //   // alert(`Story saved as ${operationResultInfo} successfully!`)
          }
        })
      }
    })
  }

  promptNavigationFunction(event, fetchAfterQuestion, questionId) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    let promptNumber = document.getElementById("promptNumber")
    let promptContainer = document.getElementById("promptContainer")
    let promptPreText = document.getElementById("promptPreText");
    let promptPostText = document.getElementById("promptPostText");
    let cursor = event.target.dataset.cursor
    let promptsCount = document.getElementById("promptsCount")
    let promptCountContainer = document.getElementById("promptCountContainer")
    const prevPromptButton = document.getElementById('promptBackward');
    const nextPromptButton = document.getElementById('promptForward');
  
  
    if(!fetchAfterQuestion){
      // TODO: Add validations to handle index value correctly
      if (cursor == "backward") {
        if(this.index >= 1){
          nextPromptButton.classList.remove("pointer-events-none", "opacity-50");
          this.index--
          if(this.index + 1 === 1){
            event.target.classList.add("pointer-events-none", "opacity-50");
          }
        }
      } else if (cursor == "forward") {
        if(this.index + 1 < +promptsCount.innerText){
          prevPromptButton.classList.remove("pointer-events-none", "opacity-50");
          this.index++
          if(this.index + 1 === +promptsCount.innerText){
            event.target.classList.add("pointer-events-none", "opacity-50");
          }
        }
      }
    }
    else{
      this.index = 0;
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
            
            if(!data.prompt_pretext && !data.prompt_posttext){
              promptPreText.textContent = 'No Prompt text present'
              promptPostText.textContent = ''
            }
            else{
              promptPreText.textContent = data.prompt_pretext
              promptPostText.textContent = data.prompt_posttext
            }
  
            if(fetchAfterQuestion){
              promptsCount.textContent = data.count
              if(data.count <= 1){
                nextPromptButton.classList.add("pointer-events-none", "opacity-50");
              }
              else{
                nextPromptButton.classList.remove("pointer-events-none", "opacity-50");
              }
            }
  
            promptCountContainer.style.display = 'inline'
            promptNumber.textContent = this.index + 1
            promptContainer.dataset.id = data.prompt_id
  
          } else {
            nextPromptButton.classList.add("pointer-events-none", "opacity-50");
            promptCountContainer.style.display = 'none'
            promptPreText.textContent = 'No Prompts present'
            promptPostText.textContent = ''
          }
        })
      }
    })
  }

  promptNavigation(event) {
    let questionId = document.getElementById("questionContainer").dataset.id
    this.promptNavigationFunction(event, false, questionId)
  }

  questionNavigation(event) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    let questionNumber = document.getElementById("questionNumber")
    let questionsCount = +document.getElementById("questionsCount").innerText
    let questionContainer = document.getElementById("questionContainer")
    let cursor = event.target.dataset.cursor
    let storyBuilderId = event.target.dataset.storyBuilderId
    const prevQuestionButton = document.getElementById('questionBackward');
    const nextQuestionButton = document.getElementById('questionForward');
    const prevPromptButton = document.getElementById('promptBackward');
    
    // TODO: Add validations to handle index value correctly
    if (cursor == "backward") {
      if(this.qIndex >= 1){
        nextQuestionButton.textContent = 'Next Question'
        this.qIndex--
        if(this.qIndex + 1 === 1){
          event.target.classList.add("pointer-events-none", "opacity-50");
        }
      }
    } else if (cursor == "forward") {
      if(this.qIndex + 1 < questionsCount){
        prevQuestionButton.classList.remove("pointer-events-none", "opacity-50");
        this.qIndex++
        if(this.qIndex + 1 === questionsCount){
          nextQuestionButton.textContent = 'Finish'
        }
      }
      
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
            prevPromptButton.classList.add("pointer-events-none", "opacity-50");

            this.promptNavigationFunction(event, true, data.question_id)

          } else {
            questionContainer.textContent = 'An error occurred in fetching this question'
          }
        })
      }
    })
  }

  toggleStoryVisibility(event) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    const storyId = event.target.dataset.id
    const viewableTextContainer = document.getElementById(`viewableTextContainer${storyId}`)
    
    fetch(`/stories/${storyId}/update_visibility`, { 
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
    }).then((response) => {
      if (response.ok) {
        response.json().then((data) => {
          if (data.success) {
            viewableTextContainer.textContent = data.viewable ? "Viewable" : "Non-viewable"
            // event.target.setAttribute("checked", data.viewable)
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
