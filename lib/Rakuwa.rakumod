use Crust::Request;
use Rakuwa::Conf;
use Hash::MultiValue;
use DB::MySQL;

class Rakuwa does Rakuwa::Conf {
    has Crust::Request $.request;
    has Hash::MultiValue $.params is rw;
    has %.controller is rw;
    has %.page is rw;
    has Int $.status is rw;
    has %.headers is rw;
    has DB::MySQL $.db is rw;

    method init () {
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

        # ToDo
        # Session
        # Email

    }

    method finish {
        if $.db.defined {
            $.db.finish();
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
        my @headers = [];
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

        if $script_url ~~ m/\. .**  1..4 $/ {
             # File Controller
             %.controller{'Mode'} = 'File';
             %.controller{'Controller'} = 'File';
             %.controller{'View'}       = $script_url;
        } elsif @parts[0] eq 'API' {
             %.controller{'Mode'} = 'API';
             %.headers{'Content-Type'} = 'application/json';
             if @parts[1].defined { %.controller{'Controller'} = @parts[1] }
             if @parts[2].defined { %.controller{'View'}       = @parts[2] }
             if @parts[3].defined { %.controller{'SubView'}    = @parts[3] }
             if @parts[4].defined { %.controller{'UrlId'}      = @parts[4] }
             if %.controller{'Controller'}.codes == 0 {
                 %.controller{'Controller'} = 'API';
             }
        } else {
             %.controller{'Mode'} = 'WA';
             if @parts[0].defined { %.controller{'Controller'} = @parts[0] }
             if @parts[1].defined { %.controller{'View'}       = @parts[1] }
             if @parts[2].defined { %.controller{'SubView'}    = @parts[2] }
             if @parts[3].defined { %.controller{'UrlId'}      = @parts[3] }

             if %.controller{'Controller'}.codes == 0 {
                 %.controller{'Controller'} = 'Static';
             }
        }
        if %.controller{'View'}.codes == 0 {
             %.controller{'View'} = 'Home';
        }
    }
}
