unit package Rakuwa::Blog::Routes;

use Cro::HTTP::Router;
use Rakuwa::Blog::Views;
use Rakuwa::Blog::Actions;
use Rakuwa::Blog::AdminViews;
use Rakuwa::Blog::AdminActions;
use Rakuwa::SessionObject;

sub blog-routes($Rakuwa) is export {
    route {
        get -> LoggedIn $session, 'blog-admin',*@path {
            my $function = $Rakuwa.get_view_function_name(@path);
            my $view = Rakuwa::Blog::AdminViews.new(:request(request), :$session, :@path);
            if $view.can($function) {
                $view."$function"();
                $view.render();
                content 'text/html', $view.content;
            }else{
                not-found 'text/html', $Rakuwa.not-found("View does not have a {$function} method.");
            }
        }

        post -> LoggedIn $session, 'blog-admin',*@path {
            request-body -> (*%params) {
                my $function = $Rakuwa.get_action_function_name(@path);
                my $action = Rakuwa::Blog::AdminActions.new(:request(request), :$session, :@path);
                if $action.can($function) {
                    $action."$function"(%params);
                    if ($action.redirect.chars > 0) {
                        redirect :see-other, $action.redirect;
                    }else {
                        my $view_function = $Rakuwa.get_view_function_name(@path);
                        my $view = Rakuwa::Blog::AdminViews.new(:request(request), :@path);
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

        get -> 'blog',*@path {
            my $function = $Rakuwa.get_view_function_name(@path);
            my $view = Rakuwa::Blog::Views.new(:request(request), :@path);
            if $view.can($function) {
                $view."$function"();
                $view.render();
                content 'text/html', $view.content;
            }else{
                not-found 'text/html', $Rakuwa.not-found("View does not have a {$function} method.");
            }
        }

        get -> 'blog-admin',*@path {
            redirect :see-other, '/user/login';        }

    }
}

