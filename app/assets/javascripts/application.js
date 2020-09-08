// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require sweetalert
//= require rails-ujs
//= require materialize
//= require chartkick
//= require Chart.bundle
// require turbolinks
//= require_tree .

$( document ).ready(function() {
  
  $(".dropdown-trigger").dropdown(); 
  
  $('.sidenav').sidenav();
  
  M.updateTextFields();
  
  $(".alert > .close-alert").click(function (){
    $(this).parent().hide('slow');
  });
  
  $('.button-collapse').sidenav({
      menuWidth: 300, // Default is 300
      edge: 'left', // Choose the horizontal origin
      closeOnClick: false, // Closes side-nav on <a> clicks, useful for Angular/Meteor
      draggable: true // Choose whether you can drag to open on touch screens,
  }); 
  
  $('.modal').modal();
  
  Chartkick.configure({language: "pt-BR"})

  
}); 



