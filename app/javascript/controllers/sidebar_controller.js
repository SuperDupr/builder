import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "mainContent"];

  toggleSidebar() {
    this.sidebarTarget.classList.toggle("hidden");
    this.mainContentTarget.classList.toggle("lg:ml-256");
  }
}
