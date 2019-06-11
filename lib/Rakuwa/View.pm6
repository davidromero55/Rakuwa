use Rakuwa;

role Rakuwa::View {
    has Rakuwa $.rakuwa;
    has Str $.template is rw;

    method process () returns Str {
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
            if "$full_template_name".IO.e {
                return self."$sub_name"();
            }else{
                return "Template $.template does not exist.";
            }
        }
    }

    method display_home () returns Str {
        return "DISPLAY HOME Called";
    }
}
