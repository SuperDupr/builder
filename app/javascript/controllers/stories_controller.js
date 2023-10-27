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
          } else if (data.operation === "draft_mode") {
            operationResultInfo = data.status
            alert(`Story saved as ${operationResultInfo} successfully!`)
          }
        })
      }
    })
  }

  promptNavigationFunction(event, fetchAfterQuestion, questionId, storyId) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    let cursor = event.target.dataset.cursor
    let promptsCount = document.getElementById("promptsCount")
    const answerProviderArea = document.getElementById("answerProvider")
    const promptForward = document.getElementById('promptForward')
    const promptBackward = document.getElementById('promptBackward')

    if (!fetchAfterQuestion) {
      if (cursor === "backward") {
        this.index--
      } else if (cursor === "forward") {
        this.index++
      }
    } else {
      this.index = 0
    }
    this.saveAnswer()
    if(this.saveAnswer()){

      fetch(`/question/${questionId}/prompts?index=${this.index}&story_id=${storyId}`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        }
      }).then((response) => {
          if (response.ok) {
          response.json().then((data) => {
            if (data.success) {
              answerProviderArea.innerHTML = ""
  
              if (data.nodes_without_prompt) {
                console.log("I am here!")
                // Scenario 2: Construct the answer field with prompt data, counter, navigation buttons, nodes and sub-nodes
                answerProviderArea.innerHTML = this.constructSelectionElementForNodes(data.nodes, data.answer)
              } else {
                // Scenario 1: Construct the answer field with prompt data, counter, navigation buttons, nodes and sub-nodes
                answerProviderArea.innerHTML = this.constructDataPerPrompt(data.count, this.index, data.prompt_id, data.prompt_pretext, data.prompt_posttext, data.prompt_selector, data.nodes)
                
                if(!fetchAfterQuestion){
                  if (cursor == "backward") {
                    if(this.index >= 1){
                      promptForward?.classList.remove("pointer-events-none", "opacity-50");
                      if(this.index === 0){
                        promptBackward?.classList.add("pointer-events-none", "opacity-50");
                      }
                    }
                  } else if (cursor == "forward") {
                    if(this.index < +promptsCount.innerText) {
                      promptBackward?.classList.remove("pointer-events-none", "opacity-50");
    
                      if ((this.index + 1) === +promptsCount.innerText) {
                        promptForward?.classList.add("pointer-events-none", "opacity-50");
                      }
                    }
                  }
                } else {
                  if(data.count <= 1){
                    promptForward?.classList.add("pointer-events-none", "opacity-50");
                  }
                  else{
                    promptForward?.classList.remove("pointer-events-none", "opacity-50");
                  }
                }
              }
  
              // TODO: Add validations to handle index value correctly
            } else {
              // Scenario 2: Construct the answer field with text area
              answerProviderArea.innerHTML = ""
              answerProviderArea.innerHTML = this.constructDataPerAnswerTextArea(data.answer)
            }
          })
        }
      })
    }
    else{
      promptForward?.classList.add("pointer-events-none");
    }
  }

  constructSelectionElementForNodes(nodes, answerSelector) {
    const answerProvider = document.getElementById("answerProvider")
    answerProvider.setAttribute("data-only-node-mode", "on")
    answerProvider.setAttribute("data-prompt-mode", "off")

    let selectHTML =
    `<div class="min-h-400 flex-col"><select id="nodes" class="!w-auto mx-auto slec-without-border" data-action="change->stories#disableNavigationButtonsOnChange"><option value="">select</option>`

    for (let i = 0; i < nodes.length; i++) {
      const node = nodes[i];
      if(node.child_nodes.length > 0){
        selectHTML += `<optgroup label="${node.title}">`
        for (let j = 0; j < node.child_nodes.length; j++) {
          const child_node = node.child_nodes[j];
          let shouldSelect = child_node.title === answerSelector
  
          selectHTML += `<option value="${child_node.id}" ${shouldSelect ? 'selected' : ''}>${child_node.title}</option>`;
        }
  
        selectHTML += `</optgroup>`
      }
      else{
        let shouldSelect = node.title === answerSelector
        selectHTML += `<option value="${node.id}" ${shouldSelect ? 'selected' : ''}>${node.title}</option>`;
      }
    }

    selectHTML += `</select>`

    return `
      <h5 class="w-full mb-6">Select an option</h5>
      ${selectHTML}
      <div id="errorText" class="text-red-500 text-center mt-1 hidden block fs-15">Please select an option to save response</div>
      </div>
    `
  }

  constructDataPerPrompt(totalPromptsCount, promptIndex, promptId, promptPreText, promptPostText, promptSelector, nodes) {
    document.getElementById("answerProvider").dataset.promptMode = "on"
    document.getElementById("answerProvider").setAttribute("data-only-node-mode", "off")
    console.log(promptSelector)
    let selectHTML =
      `<select id="nodes" data-action="change->stories#disableNavigationButtonsOnChange" class="!w-auto slec-without-border"><option value="">select</option>`
    for (let i = 0; i < nodes.length; i++) {
      const node = nodes[i];
      if(node.child_nodes.length > 0){
        selectHTML += `<optgroup label="${node.title}">`
        for (let j = 0; j < node.child_nodes.length; j++) {
          const child_node = node.child_nodes[j];
          let shouldSelect = child_node.title === promptSelector
  
          selectHTML += `<option value="${child_node.title}" ${shouldSelect ? 'selected' : ''}>${child_node.title}</option>`;
        }
  
        selectHTML += `</optgroup>`
      }
      else{
        let shouldSelect = node.title === promptSelector
        selectHTML += `<option value="${node.title}" ${shouldSelect ? 'selected' : ''}>${node.title}</option>`;
      }
    }

    selectHTML += `</select>`
    return `
      <div class="flex items-center justify-between w-full gap-2 mb-6">
        <h5>
          Prompts 
          <span class="font-normal" id="promptCountContainer" style="display: inline;">
            <span id="promptNumber">${promptIndex + 1}</span>
            /
            <span id="promptsCount">${totalPromptsCount}</span>
          </span>
        </h5>
        <div class="flex items-center gap-2">
          <i class="fa-solid fa-circle-arrow-left fa-2x cursor-pointer text-primary ${totalPromptsCount <= 1 ? '!hidden' : ''} ${promptIndex === 0 ? 'pointer-events-none opacity-50' : ''}" id="promptBackward" data-action="click->stories#promptNavigation" data-cursor="backward"></i>
          <i class="fa-solid fa-circle-arrow-right fa-2x cursor-pointer text-primary ${totalPromptsCount <= 1 ? '!hidden' : ''}" id="promptForward" data-action="click->stories#promptNavigation" data-cursor="forward"></i>
        </div>
      </div>
      <div class="min-h-400 flex-col">
        <div id="promptContainer" class="w-full flex items-center gap-3 flex-wrap justify-center" data-id="${promptId}">
          <div id="promptPreText" class="fs-20">${promptPreText}</div>
          ${selectHTML}
          <div id="promptPostText" class="fs-20">${promptPostText}</div>
       </div>
      <div id="errorText" class="text-red-500 text-center mt-1 hidden">Please select an option to save response</div>
      </div>
    `
  }

  constructDataPerAnswerTextArea(answer) {
    const answerProvider = document.getElementById("answerProvider")
    answerProvider.dataset.promptMode = "off"
    answerProvider.setAttribute("data-only-node-mode", "off")
    
    return `
      <h5 class="w-full mb-6">Answer</h5>
      <div class="min-h-400 flex-col">
      <textarea name="answer" id="answer" data-action="input->stories#disableNavigationButtonsOnChange" value="${answer}" class="form-control lg:w-2/3 xl:w-1/2 mx-auto" placeholder="Provide your answer here.." rows="3">${answer ? answer : ""}</textarea>
      <div id="errorText" class="text-red-500 text-center fs-15 mt-1 hidden">Please write answer to save response</div>
      </div>
      
      
    `
  }

  promptNavigation(event) {
    let questionId = document.getElementById("questionContainer").dataset.id
    let storyId = document.getElementById("storyDetails").dataset.storyId
    this.saveAnswer()
    this.promptNavigationFunction(event, false, questionId, storyId)
  }

  questionNavigation(event) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    let questionNumber = document.getElementById("questionNumber")
    let questionsCount = +document.getElementById("questionsCount").innerText
    let questionContainer = document.getElementById("questionContainer")
    let questionsNavigationSection = document.getElementById("questionsNavigationSection")
    let cursor = event.target.dataset.cursor
    let storyBuilderId = event.target.dataset.storyBuilderId
    let storyId = document.getElementById("storyDetails").dataset.storyId
    let accountId = document.getElementById("access").dataset.accountId
    const prevQuestionButton = document.getElementById('questionBackward');
    const nextQuestionButton = document.getElementById('questionForward');
    const prevPromptButton = document.getElementById('promptBackward');
    const finishLink = document.getElementById("finishLink")
    
    // TODO: Add validations to handle index value correctly
    if (cursor == "backward") {
      if(this.qIndex >= 1){
        if (nextQuestionButton.style.display === "none") {
          nextQuestionButton.style.display = "flex"
        }
        
        if (finishLink) { finishLink.remove() }

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
          nextQuestionButton.style.display = "none"
          questionsNavigationSection.innerHTML +=  `<a href='/accounts/${accountId}/stories/${storyId}' class='btn btn-gray' id="finishLink" data-method="patch">Get me a Metaphor</a>`
        }
      }
    }

    this.saveAnswer()
    if(this.saveAnswer()){
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
  
              this.promptNavigationFunction(event, true, data.question_id, storyId)
  
            } else {
              questionContainer.textContent = 'An error occurred in fetching this question'
            }
          })
        }
      })
    }
    else{
      nextQuestionButton?.classList.add("pointer-events-none");
      finishLink?.classList.add("pointer-events-none");
    }
  }

  disableNavigationButtonsOnChange(event){
    const promptForward = document.getElementById('promptForward')
    const nextQuestionButton = document.getElementById('questionForward');
    const finishButton = document.getElementById('finishLink');
    const errorText = document.getElementById("errorText")
    
    if(event.target.value === ''){
      nextQuestionButton?.classList.add("pointer-events-none");
      promptForward?.classList.add("pointer-events-none");
      finishButton?.classList.add("pointer-events-none");
      errorText.classList.remove("hidden");
    }
    else{
      nextQuestionButton?.classList.remove("pointer-events-none");
      promptForward?.classList.remove("pointer-events-none");
      finishButton?.classList.remove("pointer-events-none");
      errorText.classList.add("hidden");
    }

  }

  // stopNavigation() {
  //   const answerProvider = document.getElementById("answerProvider")
  //   const promptMode = answerProvider.dataset.promptMode
  //   let response = false

  //   if (promptMode === "on") {
  //     let selectedValue = document.getElementById("nodes").value
  //     if (selectedValue === "") {
  //       alert('aaa')
  //       response = true
  //     }
  //   } else if (promptMode === "off") {
  //     let answerFieldValue

  //     if (answerProvider.dataset.onlyNodeMode === "on") {
  //       let selectElement = document.getElementById("nodes")
  //       answerFieldValue = selectElement.options[selectElement.selectedIndex].text
  //     } else {
  //       answerFieldValue = document.getElementById("answer").value
  //     }

  //     if (answerFieldValue === "") {
  //       alert('aaa')
  //       response = true
  //     }
  //   }

  //   return response
  // }

  saveAnswer() {
    const answerProvider = document.getElementById("answerProvider")
    const promptMode = answerProvider.dataset.promptMode
    const errorText = document.getElementById("errorText")
    
    if (promptMode === "on") {
      let selectElement = document.getElementById("nodes")
      if (selectElement.value === "") {
        errorText.classList.remove("hidden");
        return false
      } else {
        errorText.classList.add("hidden");
        let questionId = document.getElementById("questionContainer").dataset.id
        let storyId = document.getElementById("storyDetails").dataset.storyId
        let promptId = document.getElementById("promptContainer").dataset.id
        let selectedText = selectElement.options[selectElement.selectedIndex].text
        this.trackAnswer(questionId, storyId, promptId, selectedText)
        return true
      }
    } else if (promptMode === "off") {
      let answerFieldValue

      if (answerProvider.dataset.onlyNodeMode === "on") {
        let selectElement = document.getElementById("nodes")
        if (selectElement.value === "") {
          errorText.classList.remove("hidden");
          return false
        } else {
          errorText.classList.add("hidden");
          answerFieldValue = selectElement.options[selectElement.selectedIndex].text
          let questionId = document.getElementById("questionContainer").dataset.id
          let storyId = document.getElementById("storyDetails").dataset.storyId
          this.trackAnswer(questionId, storyId, "", answerFieldValue)
          return true
        }
      } else {
        answerFieldValue = document.getElementById("answer").value
        let questionId = document.getElementById("questionContainer").dataset.id
        let storyId = document.getElementById("storyDetails").dataset.storyId
        this.trackAnswer(questionId, storyId, "", answerFieldValue)
      }

      if (answerFieldValue === "") {
        errorText.classList.remove("hidden");
        return false
      } else {
        errorText.classList.add("hidden");
        let questionId = document.getElementById("questionContainer").dataset.id
        let storyId = document.getElementById("storyDetails").dataset.storyId
        this.trackAnswer(questionId, storyId, "", answerFieldValue)
        return true
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
  trackAnswer(questionId, storyId, promptId, selectedText) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    // let saveAnswerButton = document.getElementById("saveAnswer")
    // saveAnswerButton.classList.add("pointer-events-none", "opacity-50");
    // saveAnswerButton.textContent = "Saving..."
    setTimeout(() => {
      fetch(`/question/${questionId}/answers?story_id=${storyId}&prompt_id=${promptId}&selector=${selectedText}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        }
      })
        .then(response => response.json())
        .then(data => {
          if (data.success) {
            console.log("Answer saved successfully:", data.answer);
            // saveAnswerButton.textContent = "Saved"
            // setTimeout(() => {
              // saveAnswerButton.classList.remove("pointer-events-none", "opacity-50");
              // saveAnswerButton.textContent = "Save"
            // }, 800);
          } else {
            console.error("Failed to save answer:", data.answer);
          }
        })
    }, 1000);
  }
  
  reconnect(event) {
    if (consumer.connection.isActive()) {
      consumer.connection.reopen()
    }
  }
}
