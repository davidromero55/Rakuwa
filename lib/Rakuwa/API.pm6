use Rakuwa;
use DB::MySQL;
use JSON::Fast;

role Rakuwa::API {
    has Rakuwa $.rakuwa;
    has DB::MySQL $.db is rw;
    has %.json is rw;
    has $.SUCCESS = "success";
    has $.ERROR = "error";

    method process () returns Str {
        #Init JSON var
        %.json{"status"} = "void";
        %.json{"msg"} = "";

        if $.rakuwa.db.defined {
            $.db = $.rakuwa.db;
        }

        my Str $sub_name = $.rakuwa.controller{'View'};
        $sub_name ~~ s:g/(<[A..Z]>)/_$0/;
        $sub_name ~~ s:g/\W//;
        $sub_name = "do" ~ $sub_name.lc;
        my $has_method = self.^lookup($sub_name);
        if $has_method.perl eq 'Mu' {
            %.json{"status"} = $.ERROR;
            %.json{"msg"} = "Method '$sub_name' not defined.";
            return to-json(%.json);
        } else {
            return  to-json( self."$sub_name"() );
        }
    }

    method do_home () returns Hash {
        return %.json;
    }
}

