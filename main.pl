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

   my $dbh = connect_to_database();

   print navigation();
   print add_products($dbh) if (defined param('add_prod'));
   print add_prod_main();
   print page_trailer();

   $dbh->disconnect();
}

# add products to the database
sub add_products() {
   my ($dbh) = @_;

   my $prod_type = param('prod_type') || "";
   my $name = param('name') || "";
   my $quant = param('quant') || "";
   my $price = param('price') || "";
   my $sale_type = param('sale_type') || "";

   $prod_type =~ s/<.*?>//g;
   $prod_type =~ s/[\"\']//g;
   $prod_type = ucfirst($prod_type);
   $name =~ s/<.*?>//g;
   $name =~ s/[\"\']//g;
   $name = ucfirst($name);
   $quant =~ s/<.*?>//g;
   $quant =~ s/[\"\']//g;
   $price =~ s/<.*?>//g;
   $price =~ s/[\"\']//g;
   $price =~ tr/,./.,/;

   $sql = "INSERT INTO prod(prod_type,name,quantity,price,bus_type) VALUES(?,?,?,?,?)";
   $sth= $dbh->prepare($sql) or die "Couldn't prepare sql: ".$dbh->errstr;
   $sth->execute($prod_type,$name,$quant,$price,$sale_type)
         or die "Couldn't execute sql: ".$sth->errstr;

   $sth->finish();

   return <<eof;
   <div class="container">
   <div class="alert alert-success">
   <h4>Produto adcionado para vender!</h4>
   </div></div>
eof
}

# main page html output
sub add_prod_main() {
   return <<eof;
   <div class="container">
   <div class="jumbotron">
   <form method="POST" onsubmit="return validate_all()" action="" class="form-horizontal">
   <h2><b> Coloque as informa&ccedil;&otilde;es sobre a mercadoria: </b></h2><br>
      <div class="form-group" id="prod_name">
       <label class="control-label col-sm-2">Nome:</label>
       <div class="col-sm-10">
         <input type="textfield" name="name" id="prod_name_textfield" class="form-control" maxlength="20">
         <span class="help-block" id="prod_name_help"></span>
       </div>
      </div>
      <div class="form-group" id="type">
       <label class="control-label col-sm-2">Tipo:</label>
       <div class="col-sm-10">
         <input type="textfield" name="prod_type" id="type_textfield" class="form-control" maxlength="20">
         <span class="help-block" id="type_help"></span>
       </div>
      </div>
      <div class="form-group" id="quant">
       <label class="control-label col-sm-2">Quantidade:</label>
       <div class="col-sm-10">
         <input type="textfield" name="quant" id="quant_textfield" class="form-control" maxlength="11">
         <span class="help-block" id="quant_help"></span>
       </div>
      </div>
      <div class="form-group" id="price">
       <label class="control-label col-sm-2">Pre&ccedil;o:</label>
       <div class="input-group">
         <span class="input-group-addon">R\$</span>
         <input type="textfield" name="price" id="price_textfield" class="form-control" maxlength="8">
       </div>
       <div class="form-group"><div class="col-sm-offset-2 col-sm-10">
         <span class="help-block" id="price_help"></span>
       </div></div>
      </div>
      <input type="hidden" name="sale_type" value="Venda">
      <div class="form-group"><div class="col-sm-offset-2 col-sm-10">
         <input type="submit" name="add_prod" id="add_prod" class="btn btn-default btn md col-offset-2" value="Vender Produto">
      </div></div>
   </form>
   </div>
   </div>
eof
}

sub connect_to_database() {
   my $host = $ENV{"OPENSHIFT_MYSQL_DB_HOST"};
   my $dbname = "testedomercado";
   my $port = $ENV{"OPENSHIFT_MYSQL_DB_PORT"};
   my $dsn = "dbi:mysql:database=$dbname;host=$host;port=$port";
   my $user = $ENV{"OPENSHIFT_MYSQL_DB_USERNAME"};
   my $pwd = $ENV{"OPENSHIFT_MYSQL_DB_PASSWORD"};
   
   return DBI->connect($dsn,$user,$pwd) 
      or die "Couldn't connect to database: $DBI::errstr";
}

# navigation bar placed at the top of the page
sub navigation {

   my $sell_bar =<<eof;
   <li><a href="main.pl"><span class="glyphicon glyphicon-plus-sign">
   </span> Vender Produto </a></li>
eof

   my $buy_bar =<<eof;
   <li><a href="search.pl"><span class="glyphicon glyphicon-usd">
   </span> Comprar Produto</a></li>
eof

   my $cart_bar =<<eof;
   <li><a href="cart.pl"><span class="glyphicon glyphicon-shopping-cart">
   </span> Produtos Comprados </a></li>
eof

   return <<eof;
   <nav class="navbar navbar-inverse">
     <div class="container-fluid">
       <div class="navbar-header">
         <a class="navbar-brand" href="index.pl">TesteDoMercado.com</a>
       </div>
       <div>
         <ul class="nav navbar-nav"></ul>
         <ul class="nav navbar-nav navbar-right">
         $sell_bar
         $buy_bar
         $cart_bar
         </ul>
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
  <script src="validation.js"></script>
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