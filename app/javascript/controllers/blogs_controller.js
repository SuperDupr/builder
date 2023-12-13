// Reconnect ActionCable after switching accounts

import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  connect() {
    this.csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  }

  toggleSwitchListener(event) {
    const blogId = event.target.dataset.id
    const isConfirmed = confirm("This will publish the blog. You can't reverse this action. Are you sure to continue?");
    
    if (!isConfirmed) {
      event.preventDefault();
      return;
    }

    fetch(`/admin/blogs/${blogId}/published`, { 
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken
      },
    }).then((response) => {
      if (response.ok) {
        response.json().then((data) => {
          alert(`Blog was published successfully!`)
        })
      }
    })
  }
  
  reconnect(event) {
    if (consumer.connection.isActive()) {
      consumer.connection.reopen()
    }
  }
}
