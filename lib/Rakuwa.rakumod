use Rakuwa::Conf;
use Rakuwa::View;
use Rakuwa::Layout;

class Rakuwa {
#    has Hash::MultiValue $.params is rw;
    has %.controller is rw;
    has %.page is rw;
    has Int $.status is rw;
    has %.headers is rw;
#    has Rakuwa::Session $.session is rw;
#    has DB::MySQL $.db is rw;

    method init () {
        $.status  = 200;
        %.headers{'Content-Type'} = 'text/html';
#        $.params = $.request.parameters;
 #       self.prepare_controller;

        # # Database
        # if $.conf{'DB'}.defined > 0 {
        #     $.db = DB::MySQL.new(
        #             :host($.conf{'DB'}{'host'}),
        #             :port($.conf{'DB'}{'port'}),
        #             :user($.conf{'DB'}{'user'}),
        #             :password($.conf{'DB'}{'password'}),
        #             :database($.conf{'DB'}{'database'}),
        #             );
        # }

        # # Session
        # $.session = Rakuwa::Session.new();
        # $.session.init((%env<HTTP_COOKIE> || ''));

    }

    method finalize {
    #   $.session.finalize();
    #   say "Finish Rakuwa2 ";
    #   say "Finish Rakuwa";
    #   say "Finish Rakuwa3 ";
    #   say $.db.raku;
    #   say "Finish Rakuwa6";
    #   say $.session.raku;
    #   say "Finish Rakuwa5";

    #   if ($.db) {
    #     say "Finish db";
    #     $.db.finish();
    #   }
    #   if ($.session) {
    #     say "Finish session";
    #     $.session.finalize();
    #   }
      say "Finish All";
    }

    method error-view ($error, @path --> Rakuwa::View) {
        my $view = Rakuwa::View.new;

        say "Title: " ~ $view.page<title>;
        $view.page<title> = "Error";

        $view.status = 404;
        $view.template = "404-view.crotmp";
        $view.data = {
            :$error,
            :path(@path.join('/'))
        };
        return $view;
    }

    method get-view (@path --> Rakuwa::View) {
        # Verify if the view exists
        my $ModuleName = @path[0].tclc if @path[0].defined;
        my $ViewName = "display_home";
        my $ViewClass = "Rakuwa::{$ModuleName}::View";
        if @path[1].defined {
            $ViewName = "display_" ~ @path[1].lc;
        }

        try {
            require ::($ViewClass);
            CATCH {
                default {
                    say "Error loading view class: {$ViewClass}";
                    return self.error-view("Failed to load view: {$ViewClass}", @path);
                }
            }
        }
        if !::($ViewClass).can('new') {
            say "View class does not have a 'new' method: {$ModuleName}::{$ViewName}";
            return self.error-view("{$ViewClass} does not have a 'new' method.", @path);
        }

        if !::($ViewClass).can($ViewName) {
            say "View class does not have a '{$ViewName}' method: {$ViewClass}";
            return self.error-view("{$ViewClass} does not have a {$ViewName} method.", @path);
        }

        say "View found: {$ModuleName}::{$ViewName}";
        my $view = ::($ViewClass).new;
        $view."$ViewName"();
        return $view;
    }

    method get-main-layout (--> Rakuwa::Layout) {
        return Rakuwa::Layout.new;
    }

}
