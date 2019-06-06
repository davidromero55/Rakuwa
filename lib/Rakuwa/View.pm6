use Rakuwa::Page;
use Crust::Request;

class Rakuwa::View does Rakuwa::Page {
    has Crust::Request $.request;
    has Hash::MultiValue $.params;
    has %.controller;

    method process () returns Str {
        my Str $HTML = '';
        for $.params.kv -> $key, $val {
            $HTML = $HTML ~ "$key = $val <br>";
        }
        my Str $sub_name = $.controller{'View'};
        $sub_name ~~ s:g/(<[A..Z]>)/_$0/;
        $sub_name ~~ s:g/\W//;
        $sub_name = "display" ~ $sub_name.lc;
        $HTML = $HTML ~ "SUBNAME -> $sub_name <br>";
        my $has_method = self.^lookup($sub_name);
        #return "-|-" ~ $has_method.perl ~ "-|-";
        if $has_method.perl eq 'Mu' {
            return "Method '$sub_name' not defined.";
            # ToDo. Send the message using a message class
            #  add_msg('danger',"sub '$sub_name' not defined.\n");
            #  return $self->get_msg();
        } else {
            return self."$sub_name"();
        }
    }

    method display_home () returns Str {
        return "DISPLAY HOME Called";
    }
}
