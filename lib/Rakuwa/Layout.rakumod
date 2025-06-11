use Rakuwa::Conf;
use Cro::WebApp::Template;

class Rakuwa::Layout {
    has $.template is rw = "layout.crotmp";

    method render ($view --> Str) {
        template-location $conf<Template><template_dir>;
        return render-template $.template, {:page($view.page), :content($view.content)};
    }
}
