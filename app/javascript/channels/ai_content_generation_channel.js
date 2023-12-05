import consumer from "./consumer"

const spinnerElement = document.querySelector(".spinnerStory")
const questionContent = document.getElementById("questionContent")
const contentBtn = document.getElementById("contentBtn")
const nextQuestionButton = document.getElementById('questionForward');
const aiContentDiv = document.getElementById("aiContentDiv")

if(spinnerElement) {
  spinnerElement.style.display = "none";
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
    const answerField = document.getElementById("answer")
    // Called when there's incoming data on the websocket for this channel
    if(spinnerElement) {
      spinnerElement.style.display = "flex";
    }

    console.log(data.body)

    questionContent.style.display = "none";
    contentBtn.innerHTML = 'Create another version'
    nextQuestionButton.style.display = 'inline-flex'
    answerField.value = data.body
    answerField.textContent = data.body
    aiContentDiv.innerHTML = 
        `<div class="contentDiv border p-3 rounded lg:w-2/3 xl:w-1/2">${data.body}</div>`
    
    
    if(spinnerElement) {
      spinnerElement.style.display = "none";
    }
  }
});