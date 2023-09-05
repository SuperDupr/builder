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
    const storyId = event.target.dataset.id
    let privateAccess = document.getElementById(`privateAccess${storyId}`);
    const accountId = event.target.dataset.accountId
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
    let cursor = event.target.dataset.cursor
    let promptsCount = document.getElementById("promptsCount")
    const answerProviderArea = document.getElementById("answerProvider")

    if (!fetchAfterQuestion) {
      if (cursor === "backward") {
        this.index--
      } else if (cursor === "forward") {
        this.index++
      }
    } else {
      this.index = 0
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
            // Scenario 1: Construct the answer field with prompt data, counter, navigation buttons, nodes and sub-nodes
            answerProviderArea.innerHTML = ""
            answerProviderArea.innerHTML = this.constructDataPerPrompt(data.count, this.index, data.prompt_id, data.prompt_pretext, data.prompt_posttext, data.prompt_selector, data.nodes)

            // TODO: Add validations to handle index value correctly
            if(!fetchAfterQuestion){
              if (cursor == "backward") {
                if(this.index >= 1){
                  document.getElementById('promptForward').classList.remove("pointer-events-none", "opacity-50");
                  if(this.index === 0){
                    document.getElementById('promptBackward').classList.add("pointer-events-none", "opacity-50");
                  }
                }
              } else if (cursor == "forward") {
                if(this.index < +promptsCount.innerText) {
                  document.getElementById('promptBackward').classList.remove("pointer-events-none", "opacity-50");

                  if ((this.index + 1) === +promptsCount.innerText) {
                    document.getElementById('promptForward').classList.add("pointer-events-none", "opacity-50");
                  }
                }
              }
            } else {
              if(data.count <= 1){
                document.getElementById('promptForward').classList.add("pointer-events-none", "opacity-50");
              }
              else{
                document.getElementById('promptForward').classList.remove("pointer-events-none", "opacity-50");
              }
            }
          } else {
            // Scenario 2: Construct the answer field with text area
            answerProviderArea.innerHTML = ""
            answerProviderArea.innerHTML = this.constructDataPerAnswerTextArea()
          }
        })
      }
    })
  }

  constructDataPerPrompt(totalPromptsCount, promptIndex, promptId, promptPreText, promptPostText, promptSelector, nodes) {
    document.getElementById("answerProvider").dataset.promptMode = "on"
    console.log(promptSelector)
    let selectHTML = promptSelector ? 
      `<select id="nodes" class="!w-auto">` :
      `<select id="nodes" class="!w-auto"><option disabled="" value="" selected="">Select option</option>`
     
    
    for (let i = 0; i < nodes.length; i++) {
      const node = nodes[i];
      if(node.child_nodes.length > 0){
        selectHTML += `<optgroup label="${node.title}">`
        for (let j = 0; j < node.child_nodes.length; j++) {
          const child_node = node.child_nodes[j];
          let shouldSelect = child_node.title === promptSelector
  
          selectHTML += `<option value="${child_node.id}" ${shouldSelect ? 'selected' : ''}>${child_node.title}</option>`;
        }
  
        selectHTML += `</optgroup>`
      }
      else{
        let shouldSelect = node.title === promptSelector
        selectHTML += `<option value="${node.id}" ${shouldSelect ? 'selected' : ''}>${node.title}</option>`;
      }
    }

    selectHTML += `</select>`
    return `
      <div class="flex items-center justify-between w-full gap-2">
        <h5>
          Prompts 
          <span class="font-normal" id="promptCountContainer" style="display: inline;">
            <span id="promptNumber">${promptIndex + 1}</span>
            /
            <span id="promptsCount">${totalPromptsCount}</span>
          </span>
        </h5>
        <div class="flex items-center gap-2">
          <i class="fa-solid fa-circle-arrow-left fa-2x cursor-pointer text-primary ${promptIndex === 0 ? 'pointer-events-none opacity-50' : ''}" id="promptBackward" data-action="click->stories#promptNavigation" data-cursor="backward"></i>
          <i class="fa-solid fa-circle-arrow-right fa-2x cursor-pointer text-primary" id="promptForward" data-action="click->stories#promptNavigation" data-cursor="forward"></i>
        </div>
      </div>
      <div id="promptContainer" class="flex items-center gap-3 flex-wrap justify-center" data-id="${promptId}">
        <div id="promptPreText">${promptPreText}</div>
        ${selectHTML}
        <div id="promptPostText">${promptPostText}</div>
      </div>
      <div class="w-full text-right">
        <a class="btn btn-primary" data-action="stories#saveAnswer" href="javascript:void(0)">Save</a>
      </div>
    `
  }

  constructDataPerAnswerTextArea() {
    document.getElementById("answerProvider").dataset.promptMode = "off"
    return `
    <h5 class="w-full">Answer</h5>
    <textarea name="answer" id="answer" class="form-control lg:w-2/3 xl:w-1/2" placeholder="Provide your answer here.." rows="3"></textarea>
    <div class="w-full text-right">
      <a class="btn btn-primary" data-action="stories#saveAnswer" href="javascript:void(0)">Save</a>
    </div>
    `
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
            if (prevPromptButton) {
              prevPromptButton.classList.add("pointer-events-none", "opacity-50");
            }

            this.promptNavigationFunction(event, true, data.question_id)

          } else {
            questionContainer.textContent = 'An error occurred in fetching this question'
          }
        })
      }
    })
  }

  saveAnswer() {
    const answerProvider = document.getElementById("answerProvider")
    const promptMode = answerProvider.dataset.promptMode
    
    if (promptMode === "on") {
      let selectedValue = document.getElementById("nodes").value
      if (selectedValue === "") {
        alert("Please select an option to save response!")
      } else {
        let questionId = document.getElementById("questionContainer").dataset.id
        let storyId = document.getElementById("storyDetails").dataset.storyId
        let promptId = document.getElementById("promptContainer").dataset.id
        let promptPreText = document.getElementById("promptPreText").textContent
        let promptPostText = document.getElementById("promptPostText").textContent
        let selectElement = document.getElementById("nodes") 
        let selectedText = selectElement.options[selectElement.selectedIndex].text
        let response = `${promptPreText} ${selectedText} ${promptPostText}`
        this.trackAnswer(questionId, storyId, promptId, selectedText, response)
      }
    } else if (promptMode === "off") {
      let answerField = document.getElementById("answer")
      
      if (answerField.value === "") {
        alert("Please add your answer in the field!")
      } else {
        console.log("Save answer on backend")
      }
    }
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
  trackAnswer(questionId, storyId, promptId, selectedText, response) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  
    fetch(`/question/${questionId}/answers?story_id=${storyId}&prompt_id=${promptId}&selector=${selectedText}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({
        response: response
      })
    })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          console.log("Answer saved successfully:", data.answer);
        } else {
          console.error("Failed to save answer:", data.answer);
        }
      })
      .catch(error => {
        console.error("Error while saving answer:", error);
      });
  }
  
  
  reconnect(event) {
    if (consumer.connection.isActive()) {
      consumer.connection.reopen()
    }
  }
}
