import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["questionNumber", "questionsCount", "questionContainer", "questionsNavigationSection",
                    "storyDetails", "questionBackward", "questionForward", "promptBackward", 
                    "finishLink", "answerProvider", "contentBtn", "questionContent", "promptContainer",
                    "promptNumber", "promptBackward", "promptForward", "promptsCount", "errorText", "answer"]

  connect() {
    this.index = 0
    this.qIndex = 0
    this.csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    this.spinner = document.querySelector(".spinnerStory")
    this.activePositions = this.questionsCountTarget.dataset.activePositions
                              .split(",").map(elem => +elem)
    this.currentQuestionPosition = this.activePositions[0]
  }

  adjustQuestionCountIndex(cursor) {
    this.cursor = cursor
    
    if (cursor === "backward") {
      if(this.qIndex >= 1){
        if (this.questionForwardTarget.style.display === "none") this.questionForwardTarget.style.display = "inline-flex"
        if (this.hasFinishLinkTarget) this.finishLinkTarget.remove()
        this.qIndex--
      }
    } else if (cursor === "forward") {
      let incrementedQIndex = this.qIndex + 1
      let parsedQuestionsCount = parseInt(this.questionsCountTarget.textContent)

      if (incrementedQIndex < parsedQuestionsCount) {
        this.questionBackwardTarget.classList.remove("pointer-events-none", "opacity-50");
        this.qIndex++

        if(incrementedQIndex + 1 === parsedQuestionsCount){
          this.questionForwardTarget.style.display = "none"
          this.questionsNavigationSectionTarget.innerHTML +=  `<a href='javascript:void(0)' class='btn btn-gray' id="finishLink" data-method="patch" data-questionnaires-target="finishLink" data-action="questionnaires#prepareAnswer">Get me a Metaphor</a>`
        }
      }
    }
  }

  adjustQuestionPositionIndex(cursor) {
    let currentPositionIndex
    let toBeNavigatedPositionIndex
    
    currentPositionIndex = this.activePositions.indexOf(this.currentQuestionPosition)
    toBeNavigatedPositionIndex = cursor === "backward" ? currentPositionIndex - 1 : currentPositionIndex + 1
    this.currentQuestionPosition = this.activePositions[toBeNavigatedPositionIndex]
  }

  handleContentBtnAndNavigation(aiMode) {
    if(aiMode){
      if(this.hasContentBtnTarget){
        this.answerTarget.value.length > 0 ?
          this.contentBtnTarget.textContent = "Create another version" :
          this.contentBtnTarget.textContent = 'Get Content'
          
        this.contentBtnTarget.style.display = 'inline-flex'
      }
    } else {
      if(this.hasContentBtnTarget){
        this.contentBtnTarget.style.display = 'none'
      }
      this.questionForwardTarget.style.display = 'inline-flex'
      // if (this.hasPromptBackwardTarget) {
      //   this.promptBackwardTarget.classList.add("pointer-events-none", "opacity-50");
      // }
    }
  }

  questionNavigation(event) {
    console.log(event)
    let storyBuilderId = event.target.dataset.storyBuilderId
    let storyId = document.getElementById("storyDetails").dataset.storyId
    let cursor = event.target.dataset.cursor
      
    this.adjustQuestionCountIndex(cursor)
    this.adjustQuestionPositionIndex(cursor)

    fetch(`/stories/${storyBuilderId}/questions?position=${this.currentQuestionPosition}&story_id=${storyId}`, { 
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken
      }
    }).then((response) => {
      if (response.ok) {
        response.json().then((data) => {
          if (data.success) {
            this.questionNumberTarget.textContent = this.qIndex + 1
            this.questionContainerTarget.dataset.id = data.question_id
            console.log(data)
            console.log("Multiple Node Selection Mode", data.multiple_node_selection_mode)
            this.questionContainerTarget.textContent = data.question_title
            this.answerProviderTarget.dataset.aicontentMode = data.ai_mode ? "on" : "off"
            this.questionContentTarget.style.display = "flex"
            
            this.displayPrompt(event, true, data.question_id, storyId, data.ai_mode)
            // this.handleContentBtnAndNavigation(data.ai_mode)

          } else {
            this.questionContainerTarget.textContent = 'An error occurred in fetching this question'
          }
        })
      }
    })
  }

  adjustPromptPositionIndex(fetchAfterQuestion, cursor) {
    if (!fetchAfterQuestion) {
      if (cursor === "backward") {
        this.index--
      } else if (cursor === "forward") {
        this.index++
      }
    } else {
      this.index = 0
    }
  }

  adjustPromptNavigation(fetchAfterQuestion, cursor, dataCount) {
    if(!fetchAfterQuestion){
      if (cursor == "backward") {
        if(this.index >= 1){
          this.promptForwardTarget?.classList.remove("pointer-events-none", "opacity-50");
          if(this.index === 0){
            this.promptBackwardTarget?.classList.add("pointer-events-none", "opacity-50");
          }
        }

        this.promptNumberTarget.textContent = this.index - 1
      } else if (cursor == "forward") {
        let promptsCount = parseInt(parseInt(this.promptsCountTarget.innerText))

        if(this.index < promptsCount) {
          this.promptBackwardTarget?.classList.remove("pointer-events-none", "opacity-50");
          
          if ((this.index + 1) === promptsCount) {
            this.promptForwardTarget?.classList.add("pointer-events-none", "opacity-50");
          }
        }

        this.promptNumberTarget.textContent = this.index + 1
      }
    } else {
      if(dataCount <= 1){
        this.promptForwardTarget?.classList.add("pointer-events-none", "opacity-50");
      }
      else{
        this.promptForwardTarget?.classList.remove("pointer-events-none", "opacity-50");
      }
    }    
  }

  buildUpAnswerAreaAfterPromptNavigation(data, fetchAfterQuestion, cursor) {
    if (data.nodes_without_prompt) {
      // Scenario 2: Construct the answer field with prompt data, counter, navigation buttons, nodes and sub-nodes

      this.answerProviderTarget.innerHTML = this.constructSelectionElementForNodes(data.html)
    } else {
      // Scenario 1: Construct the answer field with prompt data, counter, navigation buttons, nodes and sub-nodes
      this.answerProviderTarget.innerHTML = this.constructDataPerPrompt(data.html)
      
      this.adjustPromptNavigation(fetchAfterQuestion, cursor, data.count)
    }
  }

  constructSelectionElementForNodes(html) {
    this.answerProviderTarget.setAttribute("data-only-node-mode", "on")
    this.answerProviderTarget.setAttribute("data-prompt-mode", "off")

    return html
  }

  constructDataPerPrompt(html) {
    this.answerProviderTarget.setAttribute("data-prompt-mode", "on")
    this.answerProviderTarget.setAttribute("data-only-node-mode", "off")

    return html
  }

  constructDataPerAnswerTextArea(html) {
    this.answerProviderTarget.setAttribute("data-prompt-mode", "off")
    this.answerProviderTarget.setAttribute("data-only-node-mode", "off")

    return html
  }

  displayPrompt(event, fetchAfterQuestion, questionId, storyId, aiMode = false) {
    let cursor = event.target.dataset.cursor

    // let answerSaved = fetchAfterQuestion ? true : this.saveAnswer()
    let answerSaved = true
     
    if (answerSaved) {
      this.adjustPromptPositionIndex(fetchAfterQuestion, cursor)

      fetch(`/question/${questionId}/prompts?index=${this.index}&story_id=${storyId}`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken
        }
      }).then((response) => {
          if (response.ok) {
          response.json().then((data) => {
            if (data.success) {
              this.answerProviderTarget.innerHTML = ""
              this.buildUpAnswerAreaAfterPromptNavigation(data, fetchAfterQuestion, cursor)
            } else {
              // Scenario 2: Construct the answer field with text area
              this.answerProviderTarget.innerHTML = ""
              this.answerProviderTarget.innerHTML = this.constructDataPerAnswerTextArea(data.html)
            }
            this.handleContentBtnAndNavigation(aiMode)
          })
        }
      })
    } else{
      this.promptForwardTarget?.classList.add("pointer-events-none");
    }
  }

  promptNavigation(event) {
    let questionId = this.questionContainerTarget.dataset.id
    let storyId = document.getElementById("storyDetails").dataset.storyId

    this.displayPrompt(event, false, questionId, storyId)
  }

  handleCheckboxes() {
    let nodes = document.querySelectorAll(".nodes")
    let anyChecked = false
    let checkedValues = []

    nodes.forEach(function(node) {
      if (node.checked) {
        anyChecked = true
        checkedValues.push(node.dataset.text.trim())
      }
    })

    return [anyChecked, checkedValues]
  }

  handleAnswerAsPerNodeMode() {
    if (this.answerProviderTarget.dataset.onlyNodeMode === "on") {
      let checkboxesInfo = this.handleCheckboxes()

      if (!checkboxesInfo[0]) {
        this.errorTextTarget.classList.remove("hidden");
        // return false
      } else {
        this.errorTextTarget.classList.add("hidden");
        // let questionId = this.questionContainerTarget.dataset.id
        // let storyId = document.getElementById("storyDetails").dataset.storyId
        // this.trackAnswer(questionId, storyId, "", checkboxesInfo[1])
        // return true
      }
    } else if (this.answerProviderTarget.dataset.onlyNodeMode === "off") {
      let answerFieldValue = this.answerTarget.value
      const checkedValues = []

      if (answerFieldValue === '') {
        this.errorTextTarget.classList.remove("hidden");
        // return false
      } else {
        checkedValues.push(answerFieldValue)
        this.errorTextTarget.classList.add("hidden");
        // let questionId = this.questionContainer.dataset.id
        // let storyId = document.getElementById("storyDetails").dataset.storyId

        // return true
        // if (!answerTrackedBefore) {
        //   this.trackAnswer(questionId, storyId, "", checkedValues)
        //   answerTrackedBefore = true
        // }
      }

      return answerFieldValue
    }

  }

  handleAnswerAsPerAiContentMode() {
    let answerFieldValue

    if (this.answerProviderTarget.dataset.aicontentMode === "on") {
      answerFieldValue = this.answerTarget.textContent
    } else if (this.answerProviderTarget.dataset.aicontentMode === "off") {
      answerFieldValue = this.answerTarget.value
    }

    return answerFieldValue
  }

  trackAnswerAsPerValidation(event, navigator, answerFieldValue, answerTrackedBefore) {
    const checkedValues = []

    if (answerFieldValue === '') {
      this.errorTextTarget.classList.remove("hidden")
    } else {
      checkedValues.push(answerFieldValue)
      this.errorTextTarget.classList.add("hidden");
      let questionId = this.questionContainerTarget.dataset.id
      let storyId = document.getElementById("storyDetails").dataset.storyId
      console.log("When answer field is not empty string")
      if (!answerTrackedBefore) {
        this.trackAnswer(event, navigator, questionId, storyId, "", checkedValues)
      }
    }
  }

  identifyNavigationType(target) {
    if (target.includes("question")) {
      return "question"
    } else if (target.includes("prompt")) {
      return "prompt"
    } else if (target.includes("finish")) {
      return "finish"
    }
  }

  prepareAnswer(event) {
    const promptMode = this.answerProviderTarget.dataset.promptMode
    let answerTrackedBefore = false

    let navigator = this.identifyNavigationType(event.target.dataset.questionnairesTarget)
    
    if (promptMode === "on") {
      let checkboxesInfo = this.handleCheckboxes()

      if (!checkboxesInfo[0]) {
        this.errorTextTarget.classList.remove("hidden")
      } else {
        this.errorTextTarget.classList.add("hidden")
        let questionId = this.questionContainerTarget.dataset.id
        let storyId = document.getElementById("storyDetails").dataset.storyId
        let promptId = this.promptContainerTarget.dataset.id

        this.trackAnswer(event, navigator, questionId, storyId, promptId, checkboxesInfo[1])
      }
    } else if (promptMode === "off") {
      let answerFieldValue = this.handleAnswerAsPerNodeMode()

      let aiResult = this.handleAnswerAsPerAiContentMode()

      console.log(aiResult)

      this.trackAnswerAsPerValidation(event, navigator, answerFieldValue, answerTrackedBefore)
    }
  }

  performNavigation(event, navigator, storyId) {
    if (navigator === "question") {
      this.questionNavigation(event)
    } else if (navigator === "prompt") {
      this.promptNavigation(event)
    } else if (navigator === "finish") {
      this.generateFinalVersion(storyId)
    }
  }

  trackAnswer(event, navigator, questionId, storyId, promptId, selectedText) {
    const aicontentMode = this.answerProviderTarget.dataset.aicontentMode
    let cursor = event.target.dataset.cursor

    this.spinner.style.display = "flex"

    fetch(`/question/${questionId}/answers?story_id=${storyId}&prompt_id=${promptId}&selector=${selectedText}&cursor=${cursor}&ai_mode=${aicontentMode}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken
      }
    })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          console.log("Answer saved successfully:", data.answers)
          this.performNavigation(event, navigator, storyId)
          this.spinner.style.display = "none"
        } else {
          console.error("Failed to save answer:", data.answers);
        }
      })
    
  }

  generateFinalVersion(storyId) {
    let accountId = document.getElementById("access").dataset.accountId

    fetch(`/accounts/${accountId}/stories/${storyId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken
      }
    })
    .then(response => response.json())
    .then(data => {
      window.location.href = data.url
    })
  }

  fetchAiContent(){
    let storyId = document.getElementById("storyDetails").dataset.storyId
    let questionId = document.getElementById("questionContainer").dataset.id

    this.spinner.style.display = "flex"
    
    fetch(`/ai_content?question_id=${questionId}&story_id=${storyId}`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken
      }
    })
    .then(response => response.json())
    .then(data => {
      console.log("Request forwarded!")
    })
  }

  reconnect(event) {
    if (consumer.connection.isActive()) {
      consumer.connection.reopen()
    }
  }
}