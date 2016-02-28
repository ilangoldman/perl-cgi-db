#!/usr/bin/perl -w

# Ilan Goldman
# Created: 25 Feb 2016
# Teste Online Valemobi

use CGI qw/:all/;
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
use DBI;

sub main() {
    print page_header();
    warningsToBrowser(1);
    $debug = 0;

    print navigation();
    print welcome_page();
    print page_trailer();
}

# main page html content
sub welcome_page() {
   return <<eof;
   <div class="container">
   <div class="jumbotron">
   <center>
   <h1>Bem vindo ao TesteDoMercado.com</h1>
   <h2>O seu site de compras online</h2>
   <h3>Selecione abaixo a a&ccedil;&atilde;o desejada:</h3><br>
   <p><a href="main.pl" class="btn btn-primary btn-lg"><span class="glyphicon glyphicon-plus-sign"></span> Vender produto</a></p>
   <p><a href="search.pl" class="btn btn-primary btn-lg"><span class="glyphicon glyphicon-usd"></span> Comprar produto</a></p>
   <p><a href="cart.pl" class="btn btn-primary btn-lg"><span class="glyphicon glyphicon-shopping-cart"></span> Produtos comprados</a></p>
   </center>
   </div>
   </div>
eof
}

# navigation bar placed at the top of the page
sub navigation {

   return <<eof;
   <nav class="navbar navbar-inverse">
     <div class="container-fluid">
       <div class="navbar-header">
         <a class="navbar-brand" href="index.pl">TesteDoMercado.com</a>
       </div>
       <div>
         <ul class="nav navbar-nav"></ul>
       </div>
     </div>
   </nav>
eof
}

sub page_header {
   return <<eof
Content-Type: text/html

<!DOCTYPE html>
<html lang="en">
<head>
<title>Teste Online</title>
  <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
  <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
</head>
<body>
eof
}

sub page_trailer {
   my $html = "";
   $html .= join("", map("<!-- $_=".param($_)." -->\n", param())) if $debug;
   $html .= end_html;
   return $html;
}

main();