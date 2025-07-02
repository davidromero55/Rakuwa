use Rakuwa::Conf;
use Template6;

class Rakuwa::Layout {
    has $.template is rw = "layout.crotmp";
    has %.conf  = Rakuwa::Conf.new.get-all;
    method render ($view --> Str) {
        my $TT = Template6.new();
        $TT.add-path(%.conf<Template><template_dir> ~ '/');
        return $TT.process("layout",
                :page($view.page),
                :content($view.content),
                );
    }

}
