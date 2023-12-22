import consumer from "./consumer"

consumer.subscriptions.create("StoryGenerationChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    this.spinnerElement = document.querySelector(".spinnerStory")
    this.storyContentElement = document.querySelector(".story_content")
    this.aiContentElement = document.getElementById("aiContent")
    
    if (this.storyContentElement && this.aiContentElement) {
      this.spinnerElement.style.display = "flex"
  
      if (this.aiContentElement.textContent.length > 0) {
        this.spinnerElement.style.display = "none"
      }
    }
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    this.spinnerElement.style.display = "none"
    this.aiContentElement.textContent = data.body
  }
});
