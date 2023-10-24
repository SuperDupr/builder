import consumer from "./consumer"

consumer.subscriptions.create("StoryGenerationChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("We are connected to StoryGenerationChannel!")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("We are disconnected to StoryGenerationChannel!")
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log(data.body)

    const storyContentElement = document.querySelector(".story_content")

    storyContentElement.textContent = data.body
  }
});
