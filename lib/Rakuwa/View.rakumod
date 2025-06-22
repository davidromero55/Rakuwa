use Rakuwa::Conf;
use Rakuwa::Layout;
use Template6;

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

            my $TT = Template6.new();
            $TT.add-path($conf<Template><template_dir> ~ '/');
            $.content = $TT.process(.template,
                    :data($.data),
                    :page($.page)
                    );
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
