use Crust::Request;
use Rakuwa;
use Rakuwa::Conf;
use Rakuwa::File;
use Rakuwa::Layout;
use Rakuwa::View;
use Rakuwa::Test::Controller;

class Rakuwa::Handler does Callable does Rakuwa::Conf {
    has @.body    is rw;

    method CALL-ME(%env) {
        self.call(%env);
    }

    method call(%env) {
         # Init request results

         @.body = [];
         my $Request = Crust::Request.new(%env);
         my $Rakuwa = Rakuwa.new( request => Crust::Request.new(%env) );
         $Rakuwa.init(%env);

         # Static Files
         if $Rakuwa.controller{'Controller'} eq 'File' {
             my $File = Rakuwa::File.new(rakuwa => $Rakuwa);
             @.body.push( $File.process );
             return $Rakuwa.get_status , $Rakuwa.get_headers, @.body;
         }

        # Controller exist?
        my $dynamic_module_name = 'Rakuwa::' ~ $Rakuwa.controller{'Controller'} ~ '::Controller';
        try require ::($dynamic_module_name);
        if ::($dynamic_module_name) ~~ Failure {
            @.body.push( $Rakuwa.controller{'Controller'} ~ " controller does not exist." ~ $dynamic_module_name);
            return $Rakuwa.get_status , $Rakuwa.get_headers, @.body;
        }


        # API, JSON Responses
        if $Rakuwa.controller{'Mode'} eq 'API' {
            my $dynamic_api_name = 'Rakuwa::' ~ $Rakuwa.controller{'Controller'} ~ '::API';
            try require ::($dynamic_api_name);
            if ::($dynamic_api_name) ~~ Failure {
                @.body.push( $Rakuwa.controller{'Controller'} ~ " API does not exist." ~ $dynamic_api_name);
                return $Rakuwa.get_status , $Rakuwa.get_headers, @.body;
            }

            my $Api   = ::($dynamic_api_name).new(rakuwa => $Rakuwa);
            @.body.push( $Api.process , {}, '' );
            return $Rakuwa.get_status , $Rakuwa.get_headers, @.body;
        }



        # Actions
        # HTML Responses
        $Rakuwa.init_view;
        my $Layout = Rakuwa::Layout.new(rakuwa => $Rakuwa);

        # View exist?
        my $dynamic_view_name = 'Rakuwa::' ~ $Rakuwa.controller{'Controller'} ~ '::View';
        try require ::($dynamic_view_name);
        if ::($dynamic_view_name) ~~ Failure {
            @.body.push( $Rakuwa.controller{'Controller'} ~ " controller does not exist." ~ $dynamic_view_name);
            return $Rakuwa.get_status , $Rakuwa.get_headers, @.body;
        }

        my $View   = ::($dynamic_view_name).new(rakuwa => $Rakuwa);
        @.body.push($Layout.process( $View.process , {}, '') );

        # # ENV Data
        # @.body.push("<br><br>ENV Data<br>");
        # for %env.kv -> $key, $val {
        #     @.body.push("$key => $val <br>");
        # }
        #
        # # Controller Data
        # @.body.push("<br><br>Controller<br>");
        # @.body.push(%env{'PATH_INFO'} ~ "<br>");
        # for $Rakuwa.controller.kv -> $key, $val {
        #     @.body.push("$key => $val <br>");
        # }
        #
        # # Params
        # @.body.push("<br><br>Params<br>");
        # for $.params.kv -> $key, $val {
        #     @.body.push("$key = $val <br>");
        # }
        #
        # # Response Headers
        # @.body.push("<br><br>Response Headers<br>");
        # for %.headers.kv -> $key, $val {
        #     @.body.push("$key = $val <br>");
        # }
        #
        # @.body.push('.....</body></html>');

        $Rakuwa.finalize;
        return $Rakuwa.get_status , $Rakuwa.get_headers, @.body;
     }
}
