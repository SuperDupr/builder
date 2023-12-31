// Reconnect ActionCable after switching accounts

import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  // connect() {
  // }

  toggleSwitchListener(event) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    const organizationId = event.target.dataset.id
    const isConfirmed = confirm("This will change the organization access. Are you sure to continue?");
    
    if (!isConfirmed) {
      event.preventDefault();
      return;
    }

    fetch(`/admin/accounts/${organizationId}/manage_access`, { 
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
    }).then((response) => {
      if (response.ok) {
        response.json().then((data) => {
          let status = data.access ? "activated" : "inactivated"

          alert(`Organization's access was ${status} successfully!`)
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
