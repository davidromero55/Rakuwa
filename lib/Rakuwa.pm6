use Crust::Request;
use Hash::MultiValue;

use Rakuwa::Layout;
use Rakuwa::View;


class Rakuwa does Callable
{
    has Bool $.debug = False;
    has $.status  is rw;
    has %.headers is rw;
    has @.body    is rw;
    has Crust::Request $.request is rw;
    has Hash::MultiValue $.params is rw;
    has %.controller is rw;

    method CALL-ME(%env) {
        self.call(%env);
    }

    method call(%env) {
        # Init request results
        $.status  = 200;
        %.headers{'Content-Type'} = 'text/html';
        @.body = [];

        # Request data
        $.request = Crust::Request.new(%env);

        # Params
        $.params = $.request.parameters;

        # Settings
        # Default Module

        # Read Controller data
        %.controller = self.prepare_controller(%env{'PATH_INFO'});

        # Session

        # Database

        # Email

        my $Layout = Rakuwa::Layout.new(request => $.request, params => $.params, controller => $.controller);
        my $View   = Rakuwa::View.new(request => $.request, params => $.params, controller => $.controller);

        @.body.push($Layout.process( $View.process, {}, '') );

        if $.debug {
            # ENV Data
            @.body.push("<br><br>ENV Data<br>");
            for %env.kv -> $key, $val {
                @.body.push("$key => $val <br>");
            }

            # Controller Data
            @.body.push("<br><br>Controller Data<br>");
            @.body.push(%env{'PATH_INFO'} ~ "<br>");
            for %.controller.kv -> $key, $val {
                @.body.push("$key => $val <br>");
            }

            # Params
            @.body.push("<br><br>Params<br>");
            for $.params.kv -> $key, $val {
                @.body.push("$key = $val <br>");
            }

            # Response Headers
            @.body.push("<br><br>Response Headers<br>");
            for %.headers.kv -> $key, $val {
                @.body.push("$key = $val <br>");
            }

            @.body.push('.....</body></html>');
        }

        my @headers;
        for %.headers.kv -> $key, $val {
            @headers.push($key => $val);
        }

        return $.status, @headers, @.body;
    }

    method prepare_controller(Str $path_info) returns Hash {
        my %controller = (
                'Mode' => 'WA','Layout' => 'Public',
                'Controller' => '', 'View' => '', 'SubView' => '', 'UrlId' => '');
        my @parts = split /\//, $path_info;
        @parts.shift;
        if @parts[0] eq 'API' {
            %controller{'Mode'} = 'API';
            %.headers{'Content-Type'} = 'application/json';
            if @parts[1].defined { %controller{'Controller'} = @parts[1] }
            if @parts[2].defined { %controller{'View'}       = @parts[2] }
            if @parts[3].defined { %controller{'SubView'}    = @parts[3] }
            if @parts[4].defined { %controller{'UrlId'}      = @parts[4] }
            if %controller{'Controller'}.codes == 0 {
                %controller{'Controller'} = 'API';
            }
        } else {
            %controller{'Mode'} = 'WA';
            if @parts[0].defined { %controller{'Controller'} = @parts[0] }
            if @parts[1].defined { %controller{'View'}       = @parts[1] }
            if @parts[2].defined { %controller{'SubView'}    = @parts[2] }
            if @parts[3].defined { %controller{'UrlId'}      = @parts[3] }

            if %controller{'Controller'}.codes == 0 {
                %controller{'Controller'} = 'Static';
            }
        }
        if %controller{'View'}.codes == 0 {
            %controller{'View'} = 'Home';
        }

        return %controller;
    }
}
