use Rakuwa::View;
use Hash::MultiValue;
use Template6;

class Rakuwa::Test::View does Rakuwa::View {

    method display_home () returns Str {
        my %env;
        for $.rakuwa.request.env.kv  -> $key, $val {
            %env{$key} = $val;
        }

        my %params;
        for $.rakuwa.params.kv -> $key, $val {
            %params{$key} = $val;
        }

        my $date = '';
        if $.rakuwa.db.defined {
            $date = $.rakuwa.db.query('SELECT NOW()').arrays[0];
        }
        my $TT = Template6.new(path => [$.rakuwa.conf{'App'}{'HomeDir'} ~ '/']);
        return $TT.process($.template,
                :page($.rakuwa.page), :conf($.rakuwa.conf), :controller($.rakuwa.controller),
                :params(%params), :env(%env), :headers($.rakuwa.headers), :date($date));
    }
}
