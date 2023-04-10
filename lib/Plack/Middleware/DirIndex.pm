package Plack::Middleware::DirIndex;
$Plack::Middleware::DirIndex::VERSION = '1.01';
# ABSTRACT: Append an index file to request PATH's ending with a /

use parent qw( Plack::Middleware );
use Plack::Util::Accessor qw(dir_index root);
use Plack::App::Directory;
use strict;
use warnings;
use 5.006;

=head1 NAME

Plack::Middleware::DirIndex - Middleware to use with Plack::App::Directory and the like

=head1 SYNOPSIS

  use Plack::Builder;
  use Plack::App::File;
  use Plack::Middleware::DirIndex;

  my $app = Plack::App::File->new({ root => './htdocs/' })->to_app;

  builder {
        enable "Plack::Middleware::DirIndex", dir_index => 'index.html';
        $app;
  }

=head1 DESCRIPTION

If $env->{PATH_INFO} ends with a '/' then we will append the dir_index
value to it (defaults to index.html)

=head1 COPYRIGHT & LICENSE

Copyright (c) 2012 Leo Lapworth. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut

sub directory_index {
    my ($self, $dir) = @_;

    my $dir_index = $self->dir_index();
    if (-f "${dir}.htaccess") {
      my $htaccess_dir = `grep DirectoryIndex ${dir}.htaccess`;
      if ($htaccess_dir =~ /^DirectoryIndex\s(.*?)$/) {
        $dir_index = $1;
       }
     }

    return (-f "${dir}${dir_index}" ? $dir_index : undef);
}

sub prepare_app {
    my ($self) = @_;

    $self->root('.')               unless $self->root;
    $self->dir_index('index.html') unless $self->dir_index;
}

sub call {
    my ( $self, $env ) = @_;

    if ( $env->{PATH_INFO} =~ m{/$} ) {
      my $dir = $self->root . $env->{PATH_INFO};
      my $index = $self->directory_index( $dir );
      if ($index) {
        $env->{PATH_INFO} .= $index;
       }
      else {
        return Plack::App::DirListing->new({ root => $self->root })->serve_path( $env, $dir );
       }
    }

    return $self->app->($env);
}

package Plack::App::DirListing;
use parent qw(Plack::App::Directory);

our $dir_style = <<STYLE;
body { 
	max-width: 960px;
	margin: 20px auto;
	font-family: sans-serif;
}
th, td { padding: 4px 20px }
th:nth-child(1), td:nth-child(1) { text-align: left }
th:nth-child(2), td:nth-child(2) { text-align: right }
th:nth-child(3), td:nth-child(3) { text-align: left }
th:nth-child(4), td:nth-child(4) { text-align: right }
STYLE

sub serve_path {
    my($self, $env, $dir) = @_;
    my $page = $self->SUPER::serve_path($env, $dir);
    $page->[2][0] =~ s/<\/style>/$dir_style\n<\/style>/;
    return $page;
}
1;
