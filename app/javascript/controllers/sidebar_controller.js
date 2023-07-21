import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "mainContent"];

  connect() {
    this.toggleSidebarBasedOnWindowWidth();
    window.addEventListener("resize", this.toggleSidebarBasedOnWindowWidth.bind(this));
  }

  toggleSidebarBasedOnWindowWidth() {
    if (window.innerWidth >= 992) {
      this.showSidebar();
    } else {
      this.hideSidebar();
    }
  }

  showSidebar() {
    this.sidebarTarget.classList.remove("hidden");
    this.mainContentTarget.classList.add("lg:ml-256");
  }

  hideSidebar() {
    this.sidebarTarget.classList.add("hidden");
    this.mainContentTarget.classList.remove("lg:ml-256");
  }

  toggleSidebar() {
    this.sidebarTarget.classList.toggle("hidden");
    this.mainContentTarget.classList.toggle("lg:ml-256");
  }
}
