"use strict";

function validate_all() {
   var button_class = "btn btn-default btn md col-offset-2 ";
   var type_ok, name_ok, quant_ok, price_ok;

   type_ok = type_validation();
   name_ok = name_validation();
   quant_ok = quant_validation();
   price_ok = price_validation();

   return (type_ok + name_ok + quant_ok + price_ok < 1);
}

function type_validation() {
   var type_value, error, help, ok;

   type_value = document.getElementById("type_textfield").value;

   if (typeof type_value != 'string' || type_value === "" || 
       !isLetter(type_value)) {
      error = "has-error";
      help = "Este tipo n&atilde;o &eacute; v&aacute;lido.";
      ok = 1;
   } else {
      error = "has-success";
      help = "";
      ok = 0;
   }
   
   document.getElementById("type").setAttribute("class", "form-group "+error);
   document.getElementById("type_help").innerHTML = help;

   return ok;
}

function name_validation() {
   var name_value, error, help, ok;

   name_value = document.getElementById("prod_name_textfield").value;

   if (typeof name_value != 'string' || name_value === "" ||
       !isLetter(name_value)) {
      error = "has-error";
      help = "Este nome n&atilde;o &eacute; v&aacute;lido.";
      ok = 1;
   } else {
      error = "has-success";
      help = "";
      ok = 0;
   }
   
   document.getElementById("prod_name").setAttribute("class", "form-group "+error);
   document.getElementById("prod_name_help").innerHTML = help;

   return ok;
}

function isLetter(str) {
   var first = str.charAt(0);
   return (first.length === 1 && first.match(/[a-z]/i));
}

function quant_validation() {
   var quant_value, error, help, ok;

   quant_value = document.getElementById("quant_textfield").value;

   if (isNaN(quant_value) || quant_value === "") {
      error = "has-error";
      help = "A quantidade precisa ser um n&uacute;mero.";
      ok = 1;
   } else {
      error = "has-success";
      help = "";
      ok = 0;
   }
   
   document.getElementById("quant").setAttribute("class", "form-group "+error);
   document.getElementById("quant_help").innerHTML = help;
  
   return ok;
}

function price_validation() {
   var price_value, error, help, ok;

   price_value = document.getElementById("price_textfield").value;
   price_value = price_value.replace(",",".");

   if (isNaN(price_value) || price_value === "") {
      error = "has-error";
      help = "O pre&ccedil;o precisa ser um n&uacute;mero.";
      ok = 1;
   } else {
      error = "has-success";
      help = "";
      ok = 0;
   }
   
   document.getElementById("price").setAttribute("class", "form-group "+error);
   document.getElementById("price_help").innerHTML = help;

   return ok;
}

function code_disabled() {
   var code;

   code = document.getElementById("prod_code").value;

   if (code !== "") document.getElementById('prod_name').disabled = true;
   else document.getElementById('prod_name').disabled = false;
}

function name_disabled() {
   var name;

   name = document.getElementById("prod_name").value;

   if (name !== "") document.getElementById('prod_code').disabled = true;
   else document.getElementById('prod_code').disabled = false;
}
