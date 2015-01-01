#!/usr/bin/env perl
use Archive::Zip;
use File::Temp qw(tempdir);
use Image::Magick;
use Mojolicious::Lite;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';

get '/' => sub {
  my $c = shift;
  $c->render('index');
};

post '/upload' => sub {
  my $c = shift;
  my $dir = tempdir(CLEANUP => 1);
  my $icons_dir = $dir . '/icons';
  mkdir $icons_dir;

  my $svgfile = $c->req->upload('svgfile');
  $svgfile->move_to($dir . '/input.svg');

  my $zip = Archive::Zip->new;

  my %configs = (
    'icon-60@3x' => 180
  );

  my $image = new Image::Magick;
  $image->Read($dir . '/input.svg');
  while (my ($name, $size) = each(%configs)) {
    my $filename = $icons_dir . '/' . $name . '.png';
    $image->Scale(width => $size, height => $size);
    $image->Write('png:' . $filename);
    $zip->addFile($filename);
  }

  my $content;
  open my $fh, '>', \$content;
  binmode $fh;
  $zip->writeToFileHandle($fh);
  close $fh;

  $c->res->headers->content_disposition('attachment; filename=icons.zip;');
  $c->render(data => $content, format => 'zip');
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
