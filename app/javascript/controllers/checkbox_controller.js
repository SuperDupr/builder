import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["checkbox", "buttonContainer", "selectText"];
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

  toggleSelectTextVisibility() {
    console.log(this.selectTextTarget)
    if(this.buttonContainerTarget.children.length > 0){
      this.selectTextTarget.style.display = 'none';
    }
    else{
      this.selectTextTarget.style.display = 'block';
    }
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
    this.toggleSelectTextVisibility();
  }

  createButton(labelText, checkboxId) {
    const button = document.createElement("div");
    button.classList.add("select-tag-btn");
    button.innerHTML = `${labelText.length > 15 ? labelText.slice(0, 15) + '...' : labelText} <i class="fas fa-xmark ml-2 p-1 cross cursor-pointer"></i>`;
    const crossIcon = button.querySelector(".cross");
    
    crossIcon.addEventListener("click", () => {
      const associatedCheckbox = document.getElementById(checkboxId);
      if (associatedCheckbox) {
        associatedCheckbox.checked = false;
        button.remove();
      }
      this.toggleSelectTextVisibility();
    });
    
    this.buttonContainerTarget.appendChild(button);
  }
}
