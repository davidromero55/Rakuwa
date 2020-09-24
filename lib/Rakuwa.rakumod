use Crust::Request;
use Rakuwa::Conf;
use Rakuwa::Session;
use Hash::MultiValue;
use DB::MySQL;

class Rakuwa does Rakuwa::Conf {
    has Crust::Request $.request;
    has Hash::MultiValue $.params is rw;
    has %.controller is rw;
    has %.env is rw;
    has %.page is rw;
    has Int $.status is rw;
    has %.headers is rw;
    has Rakuwa::Session $.session is rw;
    has DB::MySQL $.db is rw;

    method init (%env) {
        %.env = %env;

        $.status  = 200;
        %.headers{'Content-Type'} = 'text/html';
        $.params = $.request.parameters;
        self.prepare_controller;

        # Database
        if $.conf{'DB'}.defined > 0 {
            $.db = DB::MySQL.new(
                    :host($.conf{'DB'}{'host'}),
                    :port($.conf{'DB'}{'port'}),
                    :user($.conf{'DB'}{'user'}),
                    :password($.conf{'DB'}{'password'}),
                    :database($.conf{'DB'}{'database'}),
                    );
        }

        # Session
        $.session = Rakuwa::Session.new();
        $.session.init((%env<HTTP_COOKIE> || ''));

    }

    method finalize {
        $.session.finalize();
        say $.db.raku;
        say $.session.raku;

        if ($.db) {
            $.db.finish();
        }
        if ($.session) {
            $.session.finalize();
        }
    }

    method init_view {
        $.page{'title'}       = 'Rakuwa';
        $.page{'keywords'}    = '';
        $.page{'description'} = '';
    }
    method get_status () returns Int {
        return $.status;
    }

    method get_headers () returns Array {
        my @headers;

        %.headers{'Set-Cookie'} = $.session.get_cookie();

        for %.headers.kv -> $key, $val {
            @headers.push($key => $val);
        }
        return @headers;
    }

    method prepare_controller {
        my $script_url = $.request.env{'SCRIPT_URL'};
        %.controller = (
                'Mode' => 'WA',
                'Layout' => 'Public',
                'Controller' => '',
                'View' => '',
                'SubView' => '',
                'UrlId' => '');
        my @parts = $script_url.split('/');
        @parts.shift;

        %.controller{'Mode'} = 'WA';
        with @parts[0] { %.controller{'Controller'} = @parts[0] }
        with @parts[1] { %.controller{'View'}       = @parts[1] }
        with @parts[2] { %.controller{'SubView'}    = @parts[2] }
        with @parts[3] { %.controller{'UrlId'}      = @parts[3] }

        if %.controller{'Controller'}.codes == 0 {
             %.controller{'Controller'} = 'Static';
        }
        if %.controller{'View'}.codes == 0 {
             %.controller{'View'} = 'Home';
        }
    }
}
