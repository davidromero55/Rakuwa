unit package Rakuwa::User::Routes;

use Cro::HTTP::Router;
use Rakuwa::User::Views;
use Rakuwa::User::Actions;
use Rakuwa::SessionObject;

sub user-routes($Rakuwa) is export {
    route {

        get -> 'user','login' {
            my $view = Rakuwa::User::Views.new(:request(request), :path<login>);
            $view.execute();
            content 'text/html', $view.content;
        }

        post -> 'user', 'login' {
            request-body -> (*%params) {
                my $action = Rakuwa::User::Actions.new(:request(request), :path(['login']), :%params);
                $action.execute();
                if ($action.redirect.chars > 0) {
                    redirect :see-other, $action.redirect;
                } else {
                    my $view = Rakuwa::User::Views.new(:request(request), :path<login>);
                    $view.execute();
                    content 'text/html', $view.content;
                }
            }
        }

        get -> LoggedIn $session, 'user','logout' {
            $session.logout();
            $session.add-msg('success', 'You have been logged out.');
            redirect :see-other, '/user/login';
        }

        get -> LoggedIn $session, 'user',*@path {
            my $view = Rakuwa::User::Views.new(:request(request), :$session, :@path);
            if $view.exists() {
                $view.execute();
                content 'text/html', $view.content;
            }else{
                not-found 'text/html', $Rakuwa.not-found("View object not found.");
            }
        }

        post -> LoggedIn $session, 'user',*@path {
            request-body -> (*%params) {
                my $action = Rakuwa::User::Actions.new(:request(request), :$session, :@path);
                if $action.exists() {
                    $action.execute(%params);
                    if ($action.redirect.chars > 0) {
                        redirect :see-other, $action.redirect;
                    }else {
                        my $view = Rakuwa::User::Views.new(:request(request), :$session, :@path);
                        if $view.exists() {
                            $view.execute();
                            content 'text/html', $view.content;
                        }else {
                            not-found 'text/html', $Rakuwa
                                    .not-found("View object not found.");
                        }
                    }
                }else {
                    not-found 'text/html', $Rakuwa.not-found("Action object not found.");
                }
            }
        }

        get -> 'user',*@path {
            redirect :see-other, '/user/login';
        }

    }
}

