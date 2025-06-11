use Cro::HTTP::Router;
use Rakuwa;

sub routes() is export {
    route {

        my $Rakuwa = Rakuwa.new();
        $Rakuwa.init();

        get -> 'favicon.ico' {
            # return a 404 for favicon.ico
            content 'text/plain', "Not Found";
        }
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
        get -> 'templates', *@path {
            say "Rakuwa: Serving template resource: ", @path;
            static 'lib/templates', @path;
        }
        get -> *@path {

            if ($Rakuwa.validate-path(@path)) {
                my $view = $Rakuwa.get-view(request, @path);
                $view.render();
                content 'text/html', $view.content;
            } else {
                not-found;
            }
        }

#        post -> 'User','Login' {
#            content 'text/html', "<h1> Rakuwa </h1>";
#        }
    }

}
