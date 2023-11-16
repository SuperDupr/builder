import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["checkbox", "buttonContainer"];
  connect() {
    this.updateButtons();
  }

  initialize() {
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.addEventListener("change", () => {
        this.updateButtons();
      });
    });
  }

  updateButtons() {
    this.buttonContainerTarget.innerHTML = ""; 

    this.checkboxTargets.forEach((checkbox) => {
      const label = checkbox.parentElement; 
      const labelText = label.textContent.trim();

      if (checkbox.checked) {
        this.createButton(labelText, checkbox.id);
      }
    });
  }

  createButton(labelText, checkboxId) {
    const button = document.createElement("div");
    button.classList.add("select-tag-btn");
    button.innerHTML = `${labelText} <i class="fas fa-xmark ml-2 p-1 cross cursor-pointer"></i>`;
    const crossIcon = button.querySelector(".cross");
    
    crossIcon.addEventListener("click", () => {
      const associatedCheckbox = document.getElementById(checkboxId);
      if (associatedCheckbox) {
        associatedCheckbox.checked = false;
        button.remove();
      }
    });
    
    this.buttonContainerTarget.appendChild(button);
  }
}








