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

  promptNavigation(event) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    let promptNumber = document.getElementById("promptNumber")
    let promptContainer = document.getElementById("promptContainer")
    let promptPreText = document.getElementById("promptPreText");
    let promptPostText = document.getElementById("promptPostText");
    let questionId = document.getElementById("questionContainer").dataset.id
    let cursor = event.target.dataset.cursor
    let promptsCount = document.getElementById("promptsCount")
    const prevPromptButton = document.getElementById('promptBackward');
    const nextPromptButton = document.getElementById('promptForward');
    let promptCountContainer = document.getElementById("promptCountContainer")
    
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

  questionNavigation(event) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    let questionNumber = document.getElementById("questionNumber")
    let questionsCount = +document.getElementById("questionsCount").innerText
    let questionContainer = document.getElementById("questionContainer")
    let cursor = event.target.dataset.cursor
    let storyBuilderId = event.target.dataset.storyBuilderId
    const prevQuestionButton = document.getElementById('questionBackward');
    const nextQuestionButton = document.getElementById('questionForward');
    let promptNumber = document.getElementById("promptNumber")
    let promptContainer = document.getElementById("promptContainer")
    let promptPreText = document.getElementById("promptPreText");
    let promptPostText = document.getElementById("promptPostText");
    let promptsCount = document.getElementById("promptsCount")
    let promptCountContainer = document.getElementById("promptCountContainer")
    const prevPromptButton = document.getElementById('promptBackward');
    const nextPromptButton = document.getElementById('promptForward');
    
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

            fetch(`/question/${data.question_id}/prompts?index=0`, { 
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
                    if(data.count <= 1){
                      nextPromptButton.classList.add("pointer-events-none", "opacity-50");
                    }
                    else{
                      nextPromptButton.classList.remove("pointer-events-none", "opacity-50");
                    }
                    promptCountContainer.style.display = 'inline'
                    promptNumber.textContent = 1
                    promptContainer.dataset.id = data.prompt_id
                    promptsCount.textContent = data.count
                  } else {
                    nextPromptButton.classList.add("pointer-events-none", "opacity-50");
                    promptCountContainer.style.display = 'none'
                    promptPreText.textContent = 'No Prompts present'
                    promptPostText.textContent = ''
                  }
                })
              }
            })

            // TODO: When a new question is fetched, we have to refresh prompts as well
          } else {
            questionContainer.textContent = 'An error occurred in fetching this question'
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