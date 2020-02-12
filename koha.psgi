use Modern::Perl;

use Plack::Builder;
use Plack::App::CGIBin;
use Plack::App::Directory;
use Plack::App::URLMap;
use Plack::Request;

use Mojo::Server::PSGI;

# Pre-load libraries
use C4::Boolean;
use C4::Koha;
use C4::Languages;
use C4::Letters;
use C4::Members;
use C4::XSLT;
use Koha::Caches;
use Koha::Cache::Memory::Lite;
use Koha::Database;
use Koha::DateUtils;

use CGI qw(-utf8 ); # we will loose -utf8 under plack, otherwise
{
    no warnings 'redefine';
    my $old_new = \&CGI::new;
    *CGI::new = sub {
        my $q = $old_new->( @_ );
        $CGI::PARAM_UTF8 = 1;
        Koha::Caches->flush_L1_caches();
        Koha::Cache::Memory::Lite->flush();
        return $q;
    };
}

my $home = "/home/koha/koha";

my $apiv1 = builder {
    my $server = Mojo::Server::PSGI->new;
    $server->load_app("$home/api/v1/app.pl");
    $server->app->hook(before_dispatch => sub {
        my $c = shift;
        $c->req->url->parse('/api/' . $c->req->url->path->to_string);
    });
    $server->to_psgi_app;
};

my $opac_cgi_bin = Plack::App::CGIBin->new(
    root => "$home/opac",
)->to_app;
my $intranet_cgi_bin = Plack::App::CGIBin->new(
    root => $home,
)->to_app;

my $opac = builder {
    enable "ReverseProxy";
    enable "Plack::Middleware::Static",
        path => sub { s/_\d\d\.\d{7}\.(js|css)/.$1/, m!^/opac-tmpl/! },
        root => "$home/koha-tmpl/";
    enable "+Koha::Middleware::SetEnv";

    mount '/' => sub { [302, [Location => '/cgi-bin/koha/opac-main.pl'], ['']] },
    mount '/cgi-bin/koha' => $opac_cgi_bin;
    mount '/api' => $apiv1;
};

my $intranet = builder {
    enable "ReverseProxy";
    enable "Plack::Middleware::Static",
        path => sub { s/_\d\d\.\d{7}\.(js|css)/.$1/, m!^/intranet-tmpl/! },
        root => "$home/koha-tmpl/";
    enable "+Koha::Middleware::SetEnv";

    mount '/' => sub { [302, [Location => '/cgi-bin/koha/mainpage.pl'], ['']] },
    mount '/cgi-bin/koha' => $intranet_cgi_bin;
    mount '/api' => $apiv1;
};

my %port2app = (5000 => $intranet, 5001 => $opac);
sub {
   my $env = shift;
   $port2app{ $env->{SERVER_PORT} }->($env);
};
