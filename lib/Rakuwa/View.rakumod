use Rakuwa::Conf;
use Rakuwa::Layout;
use Cro::WebApp::Template;

class Rakuwa::View {
    has %.page is rw = {
        :title($conf<App><name>),
        :description(''),
        :keywords('')
    }
    has Int $.status is rw = 200; # Default status code
    has %.headers is rw;
    has $.content is rw = "..."; 
    has $.template is rw = "user-login-view.crotmp"; # Default template
    has %.data is rw = {};

    method render () {

        template-location $conf<Template><template_dir>;
        say "Rendering template: ", $.template;
        say "Template location set to: ", $conf<Template><template_dir>;
        $.content = render-template $.template, {data => $.data, page => $.page, debug => $conf<App><debug>};

        if $.status == 200 {
            # If the status is 200, we render the layout
            # and set the content to the layout's rendered output.
            say "Status is 200, rendering layout.";
            my $layout = Rakuwa::Layout.new;
            $.content = $layout.render(self);
            say "Layout rendered content: ", $.content.substr(0, 100); # Print first 100 chars of layout content for debugging
        }

    }

}
