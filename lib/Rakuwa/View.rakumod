use Rakuwa;
use DB::MySQL;

role Rakuwa::View {
    has Rakuwa $.rakuwa;
    has DB::MySQL $.db is rw;
    has Str $.template is rw;

    method process () returns Str {
        with $.rakuwa.db {
            $.db = $.rakuwa.db;
        }

        my Str $sub_name = $.rakuwa.controller{'View'};
        $sub_name ~~ s:g/(<[A..Z]>)/_$0/;
        $sub_name ~~ s:g/\W//;
        $sub_name = "display" ~ $sub_name.lc;
        my $has_method = self.^lookup($sub_name);
        if $has_method.perl eq 'Mu' {
            return "Method '$sub_name' not defined.";
        } else {
            $.template = 'templates/' ~ $.rakuwa.conf<Template><TemplateID> ~ '/' ~ $.rakuwa.controller{'Controller'} ~ '/' ~ $sub_name;
            my $full_template_name = $.rakuwa.conf{'App'}{'HomeDir'} ~ '/' ~ $.template ~ '.tt';

            # Some views does not require personal template, so this code goes else where
#            if "$full_template_name".IO.e {

#            }else{
#                return "Template $.template does not exist.";
#            }
            return self."$sub_name"();
        }
    }

    method display_home () returns Str {
        return "DISPLAY HOME Called";
    }
}
