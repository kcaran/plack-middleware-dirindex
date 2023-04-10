use strict;
use warnings;

use lib "lib";

use Test::More;
use Plack::Builder;
use Plack::Test;
use File::Spec;

use Plack::App::File;
use Plack::Middleware::DirIndex;
use Plack::Middleware::ErrorDocument;

BEGIN {
    use lib "t";
    require_ok "app_tests.pl";
}

my $root = File::Spec->catdir( "t", "root" );

my $app = Plack::App::File->new( { root => $root } )->to_app;
$app = Plack::Middleware::DirIndex->wrap( $app, root => $root );
$app
    = Plack::Middleware::ErrorDocument->wrap( $app, 404 => "$root/404.html" );

app_tests
    app   => $app,
    tests => [
    {   name    => 'Basic request',
        request => [ GET => '/index.html' ],
        content => 'Index',
        headers => { 'Content-Type' => 'text/html; charset=utf-8', },
    },
    {   name    => 'Index request',
        request => [ GET => '/' ],
        content => 'Index',
        headers => { 'Content-Type' => 'text/html; charset=utf-8', },
    },
    {   name    => 'Dir with no index file',
        request => [ GET => '/other/' ],
        content => qr[<title>Index of /other/</title>],
        headers => { 'Content-Type' => 'text/html; charset=utf-8', },
    },
    {   name    => 'Dir with .htaccess',
        request => [ GET => '/apache/' ],
        content => qr[Test],
        headers => { 'Content-Type' => 'text/html; charset=utf-8', },
    },
    ];

# Now test setting up alternative index (alt.html) file, not default
my $app2 = Plack::App::File->new( { root => $root } )->to_app;
$app2 = Plack::Middleware::DirIndex->wrap( $app2, dir_index => 'alt.html', root => $root );
$app2 = Plack::Middleware::ErrorDocument->wrap( $app2,
    404 => "$root/404.html");

app_tests
    app   => $app2,
    tests => [
    {   name    => 'Dir with no matching index file (now)',
        request => [ GET => '/' ],
        content => qr[<title>Index of /</title>],
        headers => { 'Content-Type' => 'text/html; charset=utf-8', },
    },
    {   name    => 'Basic request for alternative index file',
        request => [ GET => '/other/' ],
        content => 'Alt Index',
        headers => { 'Content-Type' => 'text/html; charset=utf-8', },
    },
    ];

done_testing;
