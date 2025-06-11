use Rakuwa::Conf;
use Rakuwa::Layout;
use Cro::WebApp::Template;

class Rakuwa::View {
    has %.page is rw = {
        :title($conf<App><name>),
        :description(''),
        :keywords('')
    }
    has Int $.status is rw = 0; # Default status code
    has %.headers is rw;
    has $.content is rw = "";
    has $.template is rw = ""; # Default template
    has %.data is rw = {
        :msg(''),
        :vars({}),
    };
    has @.path is rw = ();
    has $.request is rw;

    method render (%vars={}) {
        # Prepare the view for rendering
        self.prepare_for_render(%vars);

        if $.status == 0 {
            $.status = 200; # Default status code
            template-location $conf<Template><template_dir>;
            $.content = render-template $.template, {data => $.data, page => $.page, debug => $conf<App><debug>};
        }

        if $.status == 200 {
            my $layout = Rakuwa::Layout.new;
            $.content = $layout.render(self);
        }
    }

    method prepare_for_render (%vars={}) {
        $.data<vars> = %vars;

        # Prepare the view for rendering
        # Override this method in subclasses if needed
    }

}
