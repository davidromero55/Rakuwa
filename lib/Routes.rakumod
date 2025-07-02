use Cro::HTTP::Router;
use Rakuwa;
use Rakuwa::Session;
use Rakuwa::DB;
use Rakuwa::User::Views;
use Rakuwa::User::Actions;

sub routes() is export {
    route {

        my $Rakuwa = Rakuwa.new();
        $Rakuwa.init();

        before get-session();

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
        get -> 'templates', *@path {
            static 'lib/templates', @path;
        }

        get -> 'user',*@path {
            my $function = $Rakuwa.get_view_function_name(@path);
            my $view = Rakuwa::User::Views.new(:request(request), :@path);
            if $view.can($function) {
                $view."$function"();
                $view.render();
                content 'text/html', $view.content;
            }else{
                not-found 'text/html', $Rakuwa.not-found("View does not have a {$function} method.");
            }
        }

        post -> 'user',*@path {

            request-body -> (*%params) {
                my $function = $Rakuwa.get_action_function_name(@path);
                my $action = Rakuwa::User::Actions.new(:request(request), :@path);
                if $action.can($function) {
                    $action."$function"(%params);
                    if ($action.redirect.chars > 0) {
                        redirect $action.redirect;
                    }


                    my $view_function = $Rakuwa.get_view_function_name(@path);
                    my $view = Rakuwa::User::Views.new(:request(request), :@path);
                    if $view.can($view_function) {
                        $view."$view_function"();
                        $view.render();
                        content 'text/html', $view.content;
                    }else{
                        not-found 'text/html', $Rakuwa.not-found("View does not have a {$function} method.");
                    }
                }else {
                    not-found 'text/html', $Rakuwa.not-found("View does not have a {$function} method.");
                }
            }
        }

#        post -> 'User','Login' {
#            content 'text/html', "<h1> Rakuwa </h1>";
#        }
    }

}
