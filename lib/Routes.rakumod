use Cro::HTTP::Router;
use Rakuwa;
use Rakuwa::Session;
use Rakuwa::User::Views;
use Rakuwa::User::Actions;

# Rakuwa Routes
use Rakuwa::Dashboard::Routes;
use Rakuwa::SessionObject;
use Rakuwa::User::Routes;
use Rakuwa::Blog::Routes;

sub routes() is export {
    route {
        my $Rakuwa = Rakuwa.new();

        get -> Session $session {
            my $view = Rakuwa::Blog::Views.new(:request(request), :path([]), :$session, :template-dir('guest'));
            if $view.exists() {
                $view.execute();
                content 'text/html', $view.content;
            } else {
                not-found 'text/html', $Rakuwa.not-found("View object not found.");
            }
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
