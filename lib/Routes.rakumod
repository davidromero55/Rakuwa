use Cro::HTTP::Router;
use Rakuwa;

sub routes() is export {
    route {

        my $Rakuwa = Rakuwa.new();
        $Rakuwa.init();

        get -> {
            content 'text/html', "<h1> Rakuwa </h1>";
        }
#        get -> 'data', *@path {
#            # User files and data
#            static 'data', @path;
#        }
#        get -> 'vendor', *@path {
#            # Vendor libraries and static content
#            static 'vendor', @path;
#        }
        get -> 'assets', *@path {
            say "Rakuwa: Serving image: ", @path;
            static 'lib/assets', @path;
        }
#        get -> 'templates', 'main', 'css',*@path {
#            # Rakuwa css Resources
#            resource 'templates/main/css', @path;
#        }

        get -> *@path {
            my $view = $Rakuwa.get-view(@path);
            $view.render();
            content 'text/html', $view.content;
        }

#        post -> 'User','Login' {
#            content 'text/html', "<h1> Rakuwa </h1>";
#        }
    }

}
