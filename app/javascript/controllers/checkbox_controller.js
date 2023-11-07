import { Controller } from "@hotwired/stimulus"



export default class extends Controller {
  static targets = ["checkbox", "buttonContainer"];

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
    const button = document.createElement("button");
    button.classList.add("btn", "btn-primary", "select-tag-btn");
    button.innerHTML = `${labelText} <span class="ml-2 cursor-pointer cross">✖</span>`;
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








