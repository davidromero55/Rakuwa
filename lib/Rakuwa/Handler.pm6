use Crust::Request;
use Rakuwa;
use Rakuwa::Conf;
use Rakuwa::File;

class Rakuwa::Handler does Callable does Rakuwa::Conf {
    has @.body    is rw;

    method CALL-ME(%env) {
        self.call(%env);
    }

    method call(%env) {
        # Init request results
        @.body = [];

        my $Rakuwa = Rakuwa.new( request => Crust::Request.new(%env) );
        $Rakuwa.init;


        # Static Files
        if $Rakuwa.controller{'Controller'} eq 'File' {
            my $File = Rakuwa::File.new(rakuwa => $Rakuwa);
            @.body.push( $File.process );
            return $Rakuwa.get_status , $Rakuwa.get_headers, @.body;
        }

#        my $Layout = Rakuwa::Layout.new(request => $.request, params => $.params, controller => $.controller);
#        my $View   = Rakuwa::View.new(request => $.request, params => $.params, controller => $.controller);
#
#        @.body.push($Layout.process( $View.process, {}, '') );
#
#        if $.debug {
#            # ENV Data
#            @.body.push("<br><br>ENV Data<br>");
#            for %env.kv -> $key, $val {
#                @.body.push("$key => $val <br>");
#            }
#
#            # Controller Data
#            @.body.push("<br><br>Controller<br>");
#            @.body.push(%env{'PATH_INFO'} ~ "<br>");
#            for %.controller.kv -> $key, $val {
#                @.body.push("$key => $val <br>");
#            }
#
#            # Params
#            @.body.push("<br><br>Params<br>");
#            for $.params.kv -> $key, $val {
#                @.body.push("$key = $val <br>");
#            }
#
#            # Response Headers
#            @.body.push("<br><br>Response Headers<br>");
#            for %.headers.kv -> $key, $val {
#                @.body.push("$key = $val <br>");
#            }
#
#            @.body.push('.....</body></html>');
#        }

        return $Rakuwa.get_status , $Rakuwa.get_headers, @.body;
    }
}

