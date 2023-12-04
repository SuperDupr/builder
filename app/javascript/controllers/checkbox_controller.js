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
    if(this.buttonContainerTarget.children.length > 0){
      this.selectTextTarget.style.display = 'none';
    }
    else{
      this.selectTextTarget.style.display = 'block';
    }
  }

  disableCheckboxesOnSingleSelection(checkboxId) {
    const allCheckboxLabels = document.querySelectorAll('.checkboxLabel');
    const isSingleSelection = this.isSingleSelection();
  
    allCheckboxLabels.forEach((checkboxLabel) => {
      const isTargetCheckbox = checkboxLabel.getAttribute('for') === checkboxId;
      if (isSingleSelection) {
        checkboxLabel.classList.toggle("pointer-events-none", !isTargetCheckbox);
        checkboxLabel.classList.toggle("opacity-50", !isTargetCheckbox);
      } else {
        checkboxLabel.classList.remove("pointer-events-none", "opacity-50");
      }
    });
  }
  
  enableCheckboxesOnNoSelection() {
    const allCheckboxLabels = document.querySelectorAll('.checkboxLabel');
    const isSingleSelection = this.isSingleSelection();
  
    allCheckboxLabels.forEach((checkboxLabel) => {
      if (!isSingleSelection) {
        checkboxLabel.classList.remove("pointer-events-none", "opacity-50");
      }
    });
  }
  
  isSingleSelection() {
    return this.buttonContainerTarget.children.length === 1 && this.buttonContainerTarget.dataset.multiple_node === "false";
  }

  updateButtons() {
    this.buttonContainerTarget.innerHTML = ""; 

    this.checkboxTargets.forEach((checkbox) => {
      const label = checkbox.parentElement; 
      const labelText = label.textContent.trim();

      if (checkbox.checked) {
        this.createButton(labelText, checkbox.id);
        this.disableCheckboxesOnSingleSelection(checkbox.id);
      }
      else{
        this.enableCheckboxesOnNoSelection(checkbox.id);
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
      this.enableCheckboxesOnNoSelection()
      this.toggleSelectTextVisibility();
    });
    
    this.buttonContainerTarget.appendChild(button);
  }
}
