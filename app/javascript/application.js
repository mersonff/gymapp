// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"
import "trix"
import "@rails/actiontext"

Turbo.setConfirmMethod(() => {
  let dialog = document.getElementById("turbo-confirm");
  dialog.showModal();

  return new Promise((resolve, reject) => {
    dialog.addEventListener("close", (event) => {
      resolve(dialog.returnValue == 'Ok');
    }, { once: true });
  })
})
