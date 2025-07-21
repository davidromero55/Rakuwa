use Cro::HTTP::Router;
use Rakuwa;
use Rakuwa::Session;
use Rakuwa::User::Views;
use Rakuwa::User::Actions;

# Rakuwa Routes
use Rakuwa::Dashboard::Routes;
use Rakuwa::User::Routes;
use Rakuwa::Blog::Routes;

sub routes() is export {
    route {

        my $Rakuwa = Rakuwa.new();
        $Rakuwa.init();


        get -> {
            content 'text/html', "<h1> Rakuwa </h1>";
        }
        get -> 'favicon.ico' {
            # return a 404 for favicon.ico
            content 'text/plain', "Not Found";
        }
        get -> 'assets', *@path {
                static 'lib/assets', @path;
        }
        get -> 'data', *@path {
                static 'lib/data', @path;
        }
        get -> 'templates', *@path {
            static 'lib/templates', @path;
        }
        before get-session();

        include dashboard-routes($Rakuwa);

        include user-routes($Rakuwa);

        include blog-routes($Rakuwa);

    }

}
