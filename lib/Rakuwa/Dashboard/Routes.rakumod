unit package Rakuwa::Dashboard::Routes;

use Cro::HTTP::Router;
use Rakuwa::Dashboard::Views;
use Rakuwa::SessionObject;

sub dashboard-routes($Rakuwa) is export {
    route {

        get -> LoggedIn $session, 'dashboard',*@path {
            my $function = $Rakuwa.get_view_function_name(@path);
            my $view = Rakuwa::Dashboard::Views.new(:request(request), :$session, :@path);
            if $view.can($function) {
                $view."$function"();
                $view.render();
                content 'text/html', $view.content;
            }else {
                not-found 'text/html', $Rakuwa.not-found("View does not have a { $function } method.");
            }
        }
        get -> 'dashboard',*@path {
            redirect :see-other, '/user/login';
        }

    }
}

