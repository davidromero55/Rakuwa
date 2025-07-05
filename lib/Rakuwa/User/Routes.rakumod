unit package Rakuwa::User::Routes;

use Cro::HTTP::Router;
use Rakuwa::User::Views;
use Rakuwa::User::Actions;
use Rakuwa::SessionObject;

sub user-routes($Rakuwa) is export {
    route {

        get -> 'user','login' {
            my $view = Rakuwa::User::Views.new(:request(request));
            $view.display_login();
            $view.render();
            content 'text/html', $view.content;
        }

        post -> 'user', 'login' {
            request-body -> (*%params) {
                my $action = Rakuwa::User::Actions.new(:request(request));
                $action.do_login(%params);
                if ($action.redirect.chars > 0) {
                    redirect :see-other, $action.redirect;
                }else {
                    my $view = Rakuwa::User::Views.new(:request(request));
                    $view.display_login();
                    $view.render();
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
            my $function = $Rakuwa.get_view_function_name(@path);
            my $view = Rakuwa::User::Views.new(:request(request), :$session, :@path);
            if $view.can($function) {
                $view."$function"();
                $view.render();
                content 'text/html', $view.content;
            }else{
                not-found 'text/html', $Rakuwa.not-found("View does not have a {$function} method.");
            }
        }

        post -> LoggedIn $session, 'user',*@path {
            request-body -> (*%params) {
                my $function = $Rakuwa.get_action_function_name(@path);
                my $action = Rakuwa::User::Actions.new(:request(request), :$session, :@path);
                if $action.can($function) {
                    $action."$function"(%params);
                    if ($action.redirect.chars > 0) {
                        redirect :see-other, $action.redirect;
                    }else {
                        my $view_function = $Rakuwa.get_view_function_name(@path);
                        my $view = Rakuwa::User::Views.new(:request(request), :@path);
                        if $view.can($view_function) {
                            $view."$view_function"();
                            $view.render();
                            content 'text/html', $view.content;
                        }else {
                            not-found 'text/html', $Rakuwa
                                    .not-found("View does not have a { $function } method.");
                        }
                    }

                }else {
                    not-found 'text/html', $Rakuwa.not-found("View does not have a {$function} method.");
                }
            }
        }

        get -> 'user',*@path {
            redirect :see-other, '/user/login';
        }

    }
}

