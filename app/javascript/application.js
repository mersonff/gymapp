// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"
import "trix"
import "@rails/actiontext"

// Custom confirmation dialog for Turbo
Turbo.setConfirmMethod((message, element) => {
  console.log("Turbo confirm method called with message:", message);
  let dialog = document.getElementById("turbo-confirm");
  let messageElement = dialog.querySelector('.confirmation-message');
  
  // Update the confirmation message
  if (messageElement) {
    messageElement.textContent = message;
  }
  
  dialog.showModal();

  return new Promise((resolve) => {
    dialog.addEventListener("close", () => {
      console.log("Dialog closed with value:", dialog.returnValue);
      resolve(dialog.returnValue === 'ok');
    }, { once: true });
  });
});

// Fallback for delete links
document.addEventListener('DOMContentLoaded', () => {
  console.log("Setting up delete link handlers");
  
  document.addEventListener('click', (event) => {
    const link = event.target.closest('a[data-turbo-confirm]');
    if (link && link.dataset.turboMethod === 'delete') {
      console.log("Delete link clicked:", link);
      event.preventDefault();
      
      const message = link.dataset.turboConfirm;
      const dialog = document.getElementById("turbo-confirm");
      const messageElement = dialog.querySelector('.confirmation-message');
      
      if (messageElement) {
        messageElement.textContent = message;
      }
      
      dialog.showModal();
      
      dialog.addEventListener('close', () => {
        if (dialog.returnValue === 'ok') {
          console.log("User confirmed, proceeding with delete");
          // Create a form to submit the DELETE request
          const form = document.createElement('form');
          form.method = 'POST';
          form.action = link.href;
          form.style.display = 'none';
          
          const methodInput = document.createElement('input');
          methodInput.type = 'hidden';
          methodInput.name = '_method';
          methodInput.value = 'delete';
          
          const csrfToken = document.querySelector('meta[name="csrf-token"]');
          const csrfInput = document.createElement('input');
          csrfInput.type = 'hidden';
          csrfInput.name = 'authenticity_token';
          csrfInput.value = csrfToken ? csrfToken.content : '';
          
          form.appendChild(methodInput);
          form.appendChild(csrfInput);
          document.body.appendChild(form);
          form.submit();
        } else {
          console.log("User cancelled");
        }
      }, { once: true });
    }
  });
});

// Debug logging
document.addEventListener("turbo:before-fetch-request", (event) => {
  console.log("Turbo fetch request:", event.detail);
});

document.addEventListener("turbo:confirm", (event) => {
  console.log("Turbo confirm event:", event.detail);
});
