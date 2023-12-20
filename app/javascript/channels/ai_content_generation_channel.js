import consumer from "./consumer"

const spinnerElementNative = document.querySelector(".spinnerStory")
const questionContentNative = document.getElementById("questionContent")
const contentBtnNative = document.getElementById("contentBtn")
const nextQuestionButtonNative = document.getElementById('questionForward');
const aiContentDivNative = document.getElementById("aiContentDiv")
const answerFieldNative = document.getElementById("answer")

if (spinnerElementNative) {
  spinnerElementNative.style.display = "none";
}

consumer.subscriptions.create("AiContentGenerationChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("We are connected to AiContentGenerationChannel!")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("We are disconnected to AiContentGenerationChannel!")
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    if (spinnerElementNative) {
      spinnerElementNative.style.display = "flex";
    } else {
      const spinnerElement = document.querySelector(".spinnerStory")
      spinnerElement.style.display = "flex"
    }
    
    console.log(data.body)
    
    if (questionContentNative) {
      questionContentNative.style.display = "none";
    } else {
      const questionContent = document.getElementById("questionContent")
      questionContent.style.display = "none"
    }
    
    if (answerFieldNative) {
      answerFieldNative.value = data.body
      answerFieldNative.textContent = data.body
    } else {
      const answerField = document.getElementById("answer")
      answerField.value = data.body
      answerField.textContent = data.body
    }

    if (contentBtnNative) {
      contentBtnNative.innerHTML = 'Create another version'
    } else {
      const contentBtn = document.getElementById("contentBtn")
      contentBtn.innerHTML = "Create another version"
    }

    if (nextQuestionButtonNative) {
      nextQuestionButtonNative.style.display = 'inline-flex'
    } else {
      const nextQuestionButton = document.getElementById('questionForward');
      nextQuestionButton.style.display = 'inline-flex'
    }

    if (aiContentDivNative) {
      aiContentDivNative.innerHTML = `<div class="contentDiv border p-3 rounded lg:w-2/3 xl:w-1/2">${data.body}</div>`
    } else {
      const aiContentDiv = document.getElementById("aiContentDiv")
      aiContentDiv.innerHTML = `<div class="contentDiv border p-3 rounded lg:w-2/3 xl:w-1/2">${data.body}</div>`
    }
    
    if (spinnerElementNative) {
      spinnerElementNative.style.display = "none";
    } else {
      const spinnerElement2 = document.querySelector(".spinnerStory")
      spinnerElement2.style.display = "none"
    }
  }
});