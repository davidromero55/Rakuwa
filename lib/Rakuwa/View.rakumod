use Rakuwa::Conf;
use Rakuwa::Layout;
use Template6;
use Rakuwa::SessionObject;

class Rakuwa::View {
    has %.conf is rw = Rakuwa::Conf.new().get-all();
    has %.page is rw = {
        :title(%!conf<App><name>),
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
    has Rakuwa::SessionObject $.session is rw = $!request.auth; # Session object from the request

    method render (%vars={}) {
        # Prepare the view for rendering
        self.prepare_for_render(%vars);

        if $.status == 0 {
            $.status = 200; # Default status code


            my $TT = Template6.new();
            $TT.add-path(%.conf<Template><template_dir> ~ '/');
            $.content = $TT.process(.template,
                    :data($.data),
                    :page($.page),
                    :msg(self.get-msgs),
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

    method add-msg(Str $type, Str $message, :$element = '') {
        $!request.auth.add-msg($type,$message, :$element);
    }

    method get-msgs(--> Str) {
        my @msgs = $!request.auth.get-msgs;
        my $html-alerts = '';
        for @msgs -> %msg {
            # Create HTML alert messages
            $html-alerts ~= "<div class='alert alert-{%msg<type>}' role='alert'>";
            $html-alerts ~= "<strong>{%msg<message>}</strong>";
            $html-alerts ~= "</div>";
        }
        return $html-alerts;
    }



}
