# NAME

Plack::Middleware::DirIndex - Middleware to use with Plack::App::Directory and the like

# SYNOPSIS

    use Plack::Builder;
    use Plack::App::File;
    use Plack::Middleware::DirIndex;

    my $app = Plack::App::File->new({ root => './htdocs/' })->to_app;

    builder {
          enable "Plack::Middleware::DirIndex", dir_index => 'index.html';
          $app;
    }

# DESCRIPTION

If $env->{PATH\_INFO} ends with a '/' then we will append the dir\_index
value to it (defaults to index.html)

If there is no dir_index file in the directory, we will look to see if
there is an Apache-styled .htaccess file with a defined DirectoryIndex
and use that file instead.

Finally, if no file is present the directory's listing is displayed,
as in Plack::App::Directory.

# COPYRIGHT & LICENSE

Copyright (c) 2012 Leo Lapworth. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.
