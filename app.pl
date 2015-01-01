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

  my $source_file = $c->req->upload('imagefile');
  my $input_filename = $dir . '/' . $source_file->filename;
  $source_file->move_to($input_filename);

  my $zip = Archive::Zip->new;

  my %configs = (
    'icon-60@3x' => 180
  );

  my $image = new Image::Magick;
  $image->Read($input_filename);
  while (my ($name, $size) = each(%configs)) {
    my $icon_filename = $icons_dir . '/' . $name . '.png';
    $image->Scale(width => $size, height => $size);
    $image->Write('png:' . $icon_filename);
    $zip->addFile($icon_filename);
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
% title 'Home';
<form method="POST" action="/upload" enctype ="multipart/form-data">
  <fieldset>
    <legend>Upload source image</legend>
    <input type="file" name="imagefile">
    <input type="submit">
  </fieldset>
</form>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %> / App Icon Resizer</title></head>
  <body><h1>App Icon Resizer</h1><%= content %></body>
</html>
