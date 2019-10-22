use Rakuwa;
use DB::MySQL;
use JSON::Fast;

role Rakuwa::API {
    has Rakuwa $.rakuwa;
    has DB::MySQL $.db is rw;
    has %.JSON is rw;

    method process () returns Str {
        #Init JSON var
        %.JSON{"status"} = "void";
        %.JSON{"msg"} = "";

        if $.rakuwa.db.defined {
            $.db = $.rakuwa.db;
        }

        my Str $sub_name = $.rakuwa.controller{'View'};
        $sub_name ~~ s:g/(<[A..Z]>)/_$0/;
        $sub_name ~~ s:g/\W//;
        $sub_name = "do" ~ $sub_name.lc;
        my $has_method = self.^lookup($sub_name);
        if $has_method.perl eq 'Mu' {
            %.JSON{"status"} = "error";
            %.JSON{"msg"} = "Method '$sub_name' not defined.";
            return to-json(%.JSON);
        } else {
            return  to-json( self."$sub_name"() );
        }
    }

    method do_home () returns Hash {
        return %.JSON;
    }
}

