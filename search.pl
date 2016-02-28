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
   $debug = 1;

   my $dbh = connect_to_database();

   print navigation();
   print buy_prod($dbh) if (defined param('yes_buy_prod'));
   if (defined param('buy_prod')) {
      print prod_to_be_bought($dbh);
   } else {
      print search_main_page($dbh);
      print search($dbh);
   }
   print page_trailer();

   $dbh->disconnect();
}

# table of products for sale
sub search() {
   my ($dbh) = @_;
   my @db_info = ();

   my $price = param('prod_price');
   @price_range = split "-", $price;
   my $type = param('prod_type');

   my $search_condition = param("prod_name") || param('prod_code');
   $search_condition =~ s/<.*?>//g;
   $search_condition =~ s/[\"\']//g;

   # add code or name to sql
   my $search_opt = "AND ";
   if (param('prod_code') ne "") {
      $search_opt .= "code = ? ";
   } elsif (param('prod_name') ne "") {
      $search_opt .= "name = ? ";
   } else {
      $search_opt = "";
   }

   # add price to sql
   if ($price eq "1001+") {
      $search_opt .= "AND price >= 1001 ";
   } elsif ($price ne "") {
      $search_opt .= "AND price >= $price_range[0] AND price <= $price_range[1] ";
   }

   # add type to sql
   $search_opt .= "AND prod_type = ?" if ($type ne "");

   my $sql = "SELECT * FROM prod WHERE bus_type = 'Venda' $search_opt";
   my $sth = $dbh->prepare($sql);
   my $def_name = param('prod_name');

   # execute the query
   if (defined param("search_prod") and $search_condition ne ""
       and $type ne "") {
      $sth->execute($search_condition, $type);
   } elsif (defined param("search_prod") and $search_condition ne "") { 
      $sth->execute($search_condition);
   } elsif ($type ne "") {
      $sth->execute($type);
   } else {
      $sth->execute();
   }

   while (my @row = $sth->fetchrow_array()){
      push @db_info, "<tr>";
      foreach my $info (@row) {
         next if ($info eq "Compra" or $info eq "Venda"); 
         push @db_info, "<td align=\"center\">$info</td>";
      } 
      my $buy_prod = <<eof;
      <form method="POST" action="">
      <td align="center">
      <input type="submit" class="btn btn-primary btn-sm" name="buy_prod" value="Comprar">
      <input type="hidden" name="buy_prod_code" value="$row[0]">
      </td>
      </form>
eof
      push @db_info, "$buy_prod</tr>";
   }   

   if ($#db_info < 0) {
      return "<div class='container'><h2><b>Nenhum produto encontrado</b></h2></div>";
   }

   $sth->finish();
   return <<eof;
   <div class="container">
   <table class="table table-hover">
    <thead>
      <tr>
        <th class="text-center">C&oacute;digo</th>
        <th class="text-center">Tipo</th>
        <th class="text-center">Nome</th>
        <th class="text-center">Quantidade</th>
        <th class="text-center">Pre&ccedil;o</th>
        <th class="text-center"> </th>
      </tr>
    </thead>
    <tbody>
      @db_info
    </tbody>
  </table>
  </div>
eof
}

# chagind the product info from sale to purchased
sub buy_prod() {
   my ($dbh) = @_;

   my $sql = "UPDATE prod SET bus_type = ? WHERE code=?";
   my $sth = $dbh->prepare($sql) or die "Couldn't prepare sql: ".$dbh->errstr;
   my $bus_type = 'Compra';
   my $code = param("buy_prod_code");
   $dbh->do($sql, undef, $bus_type, $code);

   return <<eof;
   <div class="container">
   <div class="alert alert-success">
   <h4>Produto comprado com sucesso!</h4>
   </div></div>
eof
}

# windown to confirm purchase
sub prod_to_be_bought() {
   my ($dbh) = @_;

   my $sql = "SELECT * FROM prod WHERE code = ?";
   my $sth = $dbh->prepare($sql) or die "Couldn't prepare sql: ".$dbh->errstr;
   my $buy_code = param("buy_prod_code");

   $sth->execute($buy_code) or die "Couldn't execute sql: ".$sth->errstr;
   my @row = $sth->fetchrow_array();

   my $price = $row[4];
   $price =~ tr/.,/,./;

   return <<eof;
   <form method="POST" action="">
   <div class="container">
   <div class="jumbotron">
   <h2>Tem certeza que deseja comprar este produto? </h2><br>
   <italic><b>
   C&oacute;digo: $row[0]<br>
   Tipo: $row[1]<br>
   Nome: $row[2]<br>
   Quantidade: $row[3]<br>
   Pre&ccedil;o: R\$ $price <br>
   </italic></b><br><br>
   <input type="submit" class="btn btn-default btn-md" name="yes_buy_prod" value="Sim">
   <input type="submit" class="btn btn-default btn-md" name="no_buy_prod" value="N&atilde;o">
   <input type="hidden" name="buy_prod_code" value="$buy_code">
   </div></div>
   </form>
eof

}

# main search block
sub search_main_page() {
   my ($dbh) = @_;
   my $sql = "SELECT prod_type FROM prod WHERE bus_type = 'Venda'";
   my $sth = $dbh->prepare($sql);
   $sth->execute();

   my @seen = ();
   my $type_found = "<option> </option>";
   while (my @row = $sth->fetchrow_array()){
      if ($#seen < 0) {
         push @seen, $row[0];
         $type_found .= "<option> $row[0] </option>";
         next;
      }
      my $seen_flag = 0;
      foreach my $seen_type (@seen) {
         if ($row[0] eq "$seen_type") {
            $seen_flag = 1;
            last;
         }
      }
      if ($seen_flag == 0) {
         $type_found .= "<option> $row[0] </option>";
         push @seen, $row[0];
      }
   }

   my $textfield = <<eof;
   <div class="col-sm-10"><input type="textfield" class="form-control"></div>
eof

   return <<eof;
   <div class="container">
   <div class="jumbotron">
   <form method="POST" action="" class="form-horizontal">
   <h3>Procure pelo produto desejado atrav&eacute;s de uma das op&ccedil;&otilde;es abaixo:</h3><br>
      <div class="form-group">
         <label class="control-label col-sm-2">C&oacute;digo:</label>
         <div class="col-sm-10">
           <input type="textfield" oninput="code_disabled()" name="prod_code" id="prod_code" class="form-control" placeholder="Digite o c&oacute;digo do produto desejado">
         <br>------------------------ ou ---------------------------<br>
         </div>
      </div>

      <div class="form-group">
         <label class="control-label col-sm-2">Nome:</label>
         <div class="col-sm-10">
          <input type="textfield" oninput="name_disabled()" name="prod_name" id="prod_name" class="form-control" placeholder="Digite o nome do produto desejado">
         </div>
      </div>
   <div class="form-group">
      <label class="control-label col-sm-2">Pre&ccedil;o:</label>
      <div class="col-sm-10">
      <select class="form-control" name="prod_price" id="prod_price">
         <option></option>
         <option>0-10</option>
         <option>11-100</option>
         <option>101-1000</option>
         <option>1001+</option>
      </select>
      </div>
   </div>
   <div class="form-group">
      <label class="control-label col-sm-2">Tipos:</label>
      <div class="col-sm-10">
      <select class="form-control" name="prod_type" id="prod_type">
         $type_found
      </select>
      </div>
   </div>
   <div class="form-group"><div class="col-sm-offset-2 col-sm-10">
      <input type="submit" name="search_prod" class="btn btn-default btn md" value="Procurar">
      <input type="submit" name="search_all" class="btn btn-default btn md" value="Mostrar todos os produtos">
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