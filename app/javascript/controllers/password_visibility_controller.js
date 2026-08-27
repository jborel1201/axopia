import { Controller } from "@hotwired/stimulus"

// Toggles a password field between hidden and visible text, connect it on
// the wrapper around the input + toggle button:
//
//   %div{data: {controller: "password-visibility"}}
//     %input{type: "password", data: {password_visibility_target: "input"}}
//     %button{data: {action: "password-visibility#toggle"}}
//       %svg{data: {password_visibility_target: "iconVisible"}}
//       %svg{data: {password_visibility_target: "iconHidden"}}
export default class extends Controller {
  static targets = ["input", "iconVisible", "iconHidden"]

  toggle() {
    const isHidden = this.inputTarget.type === "password"

    this.inputTarget.type = isHidden ? "text" : "password"
    this.iconVisibleTarget.classList.toggle("d-none", isHidden)
    this.iconHiddenTarget.classList.toggle("d-none", !isHidden)
  }
}
