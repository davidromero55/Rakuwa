use Rakuwa;
use DB::MySQL;

role Rakuwa::Common {
    has Rakuwa $.rakuwa;
    has Bool $.debug = False;
    has Bool $.errors is rw = False;
    has Str $.error_msg is rw = '';

    method param(Str $name) returns Str {
        if defined $.rakuwa.params{$name} {
            return $.rakuwa.params{$name};
        } else{
            return '';
        }
    }

    method env(Str $name) returns Str {
        if defined $.rakuwa.request.env{$name} {
            return $.rakuwa.request.env{$name};
        } else{
            return '';
        }
    }

    method html_tag (Str $type, Hash %attrs, Str $content) returns Str {
        my $tag = '';
        for %attrs.kv  -> $key, $val {
            $tag = $tag ~ ' ' ~ $key ~ '="' ~ $val ~ '"';
        }
        if $content.codes > 0 {
            return '<' ~ $type ~ $tag ~ '>' ~ $content ~ '</' ~ $type ~ '>';
        }else{
            return '<' ~ $type ~ $tag ~ ' />';
        }
    }


}
