unit package Rakuwa::Dashboard::Routes;

use Cro::HTTP::Router;
use Rakuwa::Dashboard::Views;
use Rakuwa::SessionObject;

sub dashboard-routes($Rakuwa) is export {
    route {

        get -> LoggedIn $session, 'dashboard',*@path {
            my $view = Rakuwa::Dashboard::Views.new(:request(request), :$session, :@path);
            if $view.exists() {
                $view.execute();
                content 'text/html', $view.content;
            }else{
                not-found 'text/html', $Rakuwa.not-found("View object not found.");
            }
        }
        get -> 'dashboard',*@path {
            redirect :see-other, '/user/login';
        }

    }
}

