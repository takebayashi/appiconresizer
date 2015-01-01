#!/usr/bin/env perl
use Mojolicious::Lite;
use Data::Dumper;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';

get '/' => sub {
  my $c = shift;
  $c->render('index');
};

post '/upload' => sub {
  my $c = shift;
  my $svgfile = $c->req->upload('svgfile');
  # TODO: Implement image conversions
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<form method="POST" action="/upload" enctype ="multipart/form-data">
  <fieldset>
    <legend>Upload SVG</legend>
    <input type="file" name="svgfile">
    <input type="submit">
  </fieldset>
</form>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %> / svg2icons</title></head>
  <body><h1>svg2icons</h1><%= content %></body>
</html>
