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
            my $view = Rakuwa::Blog::AdminViews.new(:request(request), :$session, :@path);
            if $view.exists() {
                $view.execute();
                content 'text/html', $view.content;
            }else{
                not-found 'text/html', $Rakuwa.not-found("View object not found.");
            }
        }

        post -> LoggedIn $session, 'blog-admin',*@path {
            request-body -> (*%params) {
                my $action = Rakuwa::Blog::AdminActions.new(:request(request), :$session, :@path, :%params);
                if $action.exists() {
                    $action.execute();
                    if ($action.redirect.chars > 0) {
                        redirect :see-other, $action.redirect;
                    }else {
                        my $view = Rakuwa::Blog::AdminViews.new(:request(request), :$session, :@path);
                        if $view.exists() {
                            $view.execute();
                            content 'text/html', $view.content;
                        }else{
                            not-found 'text/html', $Rakuwa.not-found("View object not found.");
                        }
                    }
                }else {
                    not-found 'text/html', $Rakuwa.not-found("Action object not found.");
                }
            }
        }

        get -> 'blog',*@path {
            my $view = Rakuwa::Blog::Views.new(:request(request), :@path);
            if $view.exists() {
                $view.execute();
                content 'text/html', $view.content;
            }else{
                not-found 'text/html', $Rakuwa.not-found("View object not found.");
            }
        }

        get -> 'blog-admin',*@path {
            redirect :see-other, '/user/login';        }

    }
}

