use Rakuwa::Conf;
use Template6;

use Rakuwa::SessionObject;

class Rakuwa::Layout {
    has $.template is rw = "layout.crotmp";
    has %.conf  = Rakuwa::Conf.new.get-all;
    has Rakuwa::SessionObject $.session is rw;

    method render ($view --> Str) {
        my $TT = Template6.new();
        $TT.add-path(%.conf<Template><template_dir> ~ '/');
        return $TT.process("layout",
                :page($view.page),
                :content($view.content),
                :userid($.session.user-id),
                #:user-id($.session.user-id),
                #:user-name($.session.user-name),

                );
    }

}
