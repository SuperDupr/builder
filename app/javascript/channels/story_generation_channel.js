import consumer from "./consumer"

consumer.subscriptions.create("StoryGenerationChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("We are connected to StoryGenerationChannel!")
    this.spinnerElement = document.querySelector(".spinnerStory")
    this.storyContentElement = document.querySelector(".story_content")
    this.aiContentElement = document.getElementById("aiContent")
    this.showModeContainer = document.getElementById("showModeContainer")
    
    if (this.storyContentElement && this.aiContentElement) {
      if (this.spinnerElement && this.spinnerElement.dataset.showMode === "off") 
        this.spinnerElement.style.display = "flex"
  
      if (this.aiContentElement.textContent.length > 0) {
        if (this.spinnerElement) this.spinnerElement.style.display = "none"
      }
    }
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("We are disconnected to StoryGenerationChannel!")
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    if (this.showModeContainer) this.showModeContainer.style.display = "none"
    this.spinnerElement.style.display = "none"
    this.aiContentElement.textContent = data.body
  }
});
