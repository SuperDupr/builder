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

    this.saveAnswer()
    if(this.saveAnswer()){
      if (!fetchAfterQuestion) {
        if (cursor === "backward") {
          this.index--
        } else if (cursor === "forward") {
          this.index++
        }
      } else {
        this.index = 0
      }
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
    console.log(answerSelector)
    const answerProvider = document.getElementById("answerProvider")
    answerProvider.setAttribute("data-only-node-mode", "on")
    answerProvider.setAttribute("data-prompt-mode", "off")

    let selectHTML =
    `<div class="min-h-400 flex-col" id="questionContent"><div data-controller="checkbox" class="flex items-center relative">
    <div class="inline-flex items-center leading-none no-underline align-middle rounded">
    <div data-controller="dropdown">
    <div class="inline-block select-none" aria-label="Profile Menu">
    <span class="flex items-center text-gray-700 dark:text-gray-100" data-action="click->dropdown#toggle click@window->dropdown#hide" role="button"> 
      select
      <i class="fas fa-chevron-down text-xs mt-[2px] ml-2"></i>
    </span>
    </div>
    <div data-dropdown-target="menu" class="hidden mt-2 absolute left-0 dropdown-menu min-w-[250px] max-w-[350px] z-1" data-original-class="mt-2 absolute left-0 dropdown-menu min-w-[250px] max-w-[350px] z-1">
    <div class="overflow-hidden bg-white border border-gray-200 rounded shadow-md p-3">`

    for (let i = 0; i < nodes.length; i++) {
      const node = nodes[i];
      if(node.child_nodes.length > 0){
        selectHTML += `<h6 class="mb-1">${node.title}</h6>`
        for (let j = 0; j < node.child_nodes.length; j++) {
          const child_node = node.child_nodes[j];
          let shouldSelect = answerSelector?.includes(child_node.id.toString())
  
          selectHTML += `<label for="${child_node.id}" class="mb-2 flex gap-1">
            <input data-checkbox-target="checkbox" id="${child_node.id}" type="checkbox" class="mr-1 mt-[2px] nodes" value='${child_node.id}' ${shouldSelect ? 'checked' : ''}>
            ${child_node.title}
          </label>`;
        }
  
      }
      else{
        let shouldSelect = answerSelector?.includes(node.id.toString())
        selectHTML += `<label for="${node.id}" class="mb-2 flex gap-1">
          <input data-checkbox-target="checkbox" id="${node.id}" type="checkbox" class="mr-1 mt-[2px] nodes" value='${node.id}' ${shouldSelect ? 'checked' : ''}>
          ${node.title}
        </label>`;
      }
    }

    selectHTML += 
    `</div>
    </div>
    </div>
    </div>
    <div data-checkbox-target="buttonContainer" class="flex flex-wrap gap-2 ml-2"></div>
    </div>`

    return `
      <h5 class="w-full mb-6">Select an option</h5>
      ${selectHTML}
      <div id="errorText" class="text-red-500 text-center mt-1 hidden fs-15">Please select an option to save response</div>
      </div>
      <div id="aiContentDiv"></div>
    `
  }

  constructDataPerPrompt(totalPromptsCount, promptIndex, promptId, promptPreText, promptPostText, promptSelector, nodes) {
    document.getElementById("answerProvider").dataset.promptMode = "on"
    document.getElementById("answerProvider").setAttribute("data-only-node-mode", "off")
    console.log(promptSelector)
    let selectHTML =
      `<div data-controller="checkbox" class="flex items-center relative">
      <div class="inline-flex items-center leading-none no-underline align-middle rounded">
      <div data-controller="dropdown">
      <div class="inline-block select-none" aria-label="Profile Menu">
      <span class="flex items-center text-gray-700 dark:text-gray-100" data-action="click->dropdown#toggle click@window->dropdown#hide" role="button"> 
        select
        <i class="fas fa-chevron-down text-xs mt-[2px] ml-2"></i>
      </span>
      </div>
      <div data-dropdown-target="menu" class="hidden mt-2 absolute left-0 dropdown-menu min-w-[250px] max-w-[350px] z-1" data-original-class="mt-2 absolute left-0 dropdown-menu min-w-[250px] max-w-[350px] z-1">
      <div class="overflow-hidden bg-white border border-gray-200 rounded shadow-md p-3">`
    for (let i = 0; i < nodes.length; i++) {
      const node = nodes[i];
      if(node.child_nodes.length > 0){
        selectHTML += `<h6 class="mb-1">${node.title}</h6>`
        for (let j = 0; j < node.child_nodes.length; j++) {
          const child_node = node.child_nodes[j];
          let shouldSelect =  promptSelector?.includes(child_node.id.toString())
          selectHTML += `<label for="${child_node.id}" class="mb-2 flex gap-1">
            <input data-checkbox-target="checkbox" id="${child_node.id}" type="checkbox" class="mr-1 mt-[2px] nodes" value='${child_node.id}' ${shouldSelect ? 'checked' : ''}>
            ${child_node.title}
          </label>`;
        }
      }
      else{
        let shouldSelect = promptSelector?.includes(node.id.toString())
        selectHTML += `<label for="${node.id}" class="mb-2 flex gap-1">
          <input data-checkbox-target="checkbox" id="${node.id}" type="checkbox" class="mr-1 mt-[2px] nodes" value='${node.id}' ${shouldSelect ? 'checked' : ''}>
          ${node.title}
        </label>`;
      }
    }

    selectHTML += 
  ` </div>
    </div>
    </div>
    </div>
    <div data-checkbox-target="buttonContainer" class="flex flex-wrap gap-2 ml-2"></div>
    </div>`
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
      <div class="min-h-400 flex-col" id="questionContent">
        <div id="promptContainer" class="w-full flex items-center gap-3 flex-wrap justify-center" data-id="${promptId}">
          <div id="promptPreText" class="fs-20">${promptPreText}</div>
          ${selectHTML}
          <div id="promptPostText" class="fs-20">${promptPostText}</div>
       </div>
      <div id="errorText" class="text-red-500 text-center mt-1 hidden">Please select an option to save response</div>
      </div>
      <div id="aiContentDiv"></div>
    `
  }

  constructDataPerAnswerTextArea(answer) {
    const answerProvider = document.getElementById("answerProvider")
    answerProvider.dataset.promptMode = "off"
    answerProvider.setAttribute("data-only-node-mode", "off")
    
    return `
      <h5 class="w-full mb-6">Answer</h5>
      <div class="min-h-400 flex-col" id="questionContent">
      <textarea name="answer" id="answer" value='${answer?.[1] ? answer[1] : ""}' class="form-control lg:w-2/3 xl:w-1/2 mx-auto" placeholder="Provide your answer here.." rows="3">${answer?.[1] ? answer[1] : ""}</textarea>
      <div id="errorText" class="text-red-500 text-center fs-15 mt-1 hidden">Please write answer to save response</div>
      </div>
      <div id="aiContentDiv"></div>
    `
  }

  promptNavigation(event) {
    let questionId = document.getElementById("questionContainer").dataset.id
    let storyId = document.getElementById("storyDetails").dataset.storyId
    const answerProvider = document.getElementById("answerProvider")
    const aicontentMode = answerProvider.dataset.aicontentMode
    const contentBtn = document.getElementById("contentBtn");
    // if(aicontentMode === "off" || contentBtn.innerHTML === 'Create another version'){
      this.saveAnswer()
      this.promptNavigationFunction(event, false, questionId, storyId)
    // }
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
    const answerProvider = document.getElementById("answerProvider")
    const aicontentMode = answerProvider.dataset.aicontentMode
    const contentBtn = document.getElementById("contentBtn");
    const questionContent = document.getElementById("questionContent");
    
    // TODO: Add validations to handle index value correctly
    this.saveAnswer()
    if(this.saveAnswer()){
      if (cursor == "backward") {
        if(this.qIndex >= 1){
          if (nextQuestionButton.style.display === "none") {
            nextQuestionButton.style.display = "inline-flex"
          }
          
          if (finishLink) { finishLink.remove() }
  
          this.qIndex--
          // if(this.qIndex + 1 === 1){
          //   event.target.classList.add("pointer-events-none", "opacity-50");
          // }
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
              questionContent.style.display = "block";
              console.log(data.ai_mode)
              if(data.ai_mode){
                if(contentBtn){
                  contentBtn.innerHTML = 'Get Content'
                  contentBtn.style.display = 'inline-flex'
                }
                nextQuestionButton.style.display = 'none'
              }
              else{
                if(contentBtn){
                  contentBtn.style.display = 'none'
                }
                nextQuestionButton.style.display = 'inline-flex'
              }

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
  }

  // disableNavigationButtonsOnChange(event){
  //   const promptForward = document.getElementById('promptForward')
  //   const nextQuestionButton = document.getElementById('questionForward');
  //   const finishButton = document.getElementById('finishLink');
  //   const errorText = document.getElementById("errorText")
    
  //   if(event.target.value === ''){
  //     nextQuestionButton?.classList.add("pointer-events-none");
  //     promptForward?.classList.add("pointer-events-none");
  //     finishButton?.classList.add("pointer-events-none");
  //     errorText.classList.remove("hidden");
  //   }
  //   else{
  //     nextQuestionButton?.classList.remove("pointer-events-none");
  //     promptForward?.classList.remove("pointer-events-none");
  //     finishButton?.classList.remove("pointer-events-none");
  //     errorText.classList.add("hidden");
  //   }

  // }

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
      let selectCheckbox = document.querySelectorAll(".nodes")
      
      let anyChecked = false;
      const checkedValues = []
      selectCheckbox.forEach(function(checkbox) {
        if (checkbox.checked) {
          anyChecked = true;
          checkedValues.push(checkbox.dataset.text.trim());
        }
      });
      console.log(anyChecked)
      if (!anyChecked) {
        errorText.classList.remove("hidden");
        return false
      } else {
        errorText.classList.add("hidden");
        let questionId = document.getElementById("questionContainer").dataset.id
        let storyId = document.getElementById("storyDetails").dataset.storyId
        let promptId = document.getElementById("promptContainer").dataset.id
        console.log(checkedValues)
        this.trackAnswer(questionId, storyId, promptId, checkedValues)
        return true
      }
    } else if (promptMode === "off") {
      let answerFieldValue

      if (answerProvider.dataset.onlyNodeMode === "on") {
        let selectCheckbox = document.querySelectorAll(".nodes")
      
        let anyChecked = false;
        const checkedValues = []
        selectCheckbox.forEach(function(checkbox) {
          if (checkbox.checked) {
            anyChecked = true;
            checkedValues.push(checkbox.dataset.text.trim());
          }
        });
        if (!anyChecked) {
          errorText.classList.remove("hidden");
          return false
        } else {
          errorText.classList.add("hidden");
          let questionId = document.getElementById("questionContainer").dataset.id
          let storyId = document.getElementById("storyDetails").dataset.storyId
          this.trackAnswer(questionId, storyId, "", checkedValues)
          return true
        }
      } else {
        answerFieldValue = document.getElementById("answer").value
        const checkedValues = []
        if (answerFieldValue === '') {
          errorText.classList.remove("hidden");
          return false
        } else {
          checkedValues.push(answerFieldValue)
          errorText.classList.add("hidden");
          let questionId = document.getElementById("questionContainer").dataset.id
          let storyId = document.getElementById("storyDetails").dataset.storyId
          this.trackAnswer(questionId, storyId, "", checkedValues)
          // return true
        }
      }
      answerFieldValue = document.getElementById("answer").value
      const checkedValues = []
      console.log(checkedValues)
      if (answerFieldValue === '') {
        errorText.classList.remove("hidden");
        return false
      } else {
        checkedValues.push(answerFieldValue)
        errorText.classList.add("hidden");
        let questionId = document.getElementById("questionContainer").dataset.id
        let storyId = document.getElementById("storyDetails").dataset.storyId
        this.trackAnswer(questionId, storyId, "", checkedValues)
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
      console.log(selectedText)
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

  fetchAiContent(){
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    const spinnerElement = document.querySelector(".spinnerStory");
    const contentBtn = document.getElementById("contentBtn");
    const nextQuestionButton = document.getElementById('questionForward');
    const aiContentDiv = document.getElementById("aiContentDiv")
    const questionContent = document.getElementById("questionContent")
    spinnerElement.style.display = "flex";
    fetch(`/ai_content`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      }
    })
    .then(response => response.json())
    .then(data => {
      setTimeout(() => {
        spinnerElement.style.display = "none";
        questionContent.style.display = "none";
        contentBtn.innerHTML = 'Create another version'
        nextQuestionButton.style.display = 'inline-flex'
        aiContentDiv.innerHTML = 
        `<div class="contentDiv border p-3 rounded lg:w-2/3 xl:w-1/2">${data ? data.content + data.content + data.content : ""}</div>`
        console.log(data)
      }, 1000);
    })
  }

  getAiContent() {
    const contentBtn = document.getElementById("contentBtn");
    if(contentBtn.innerHTML === 'Get Content'){
      this.saveAnswer()
      if(this.saveAnswer()){
        this.fetchAiContent()
      }
    }
    else{
      this.fetchAiContent()
    }
  }
  
  reconnect(event) {
    if (consumer.connection.isActive()) {
      consumer.connection.reopen()
    }
  }
}
