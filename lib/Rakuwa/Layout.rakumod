use Rakuwa::Conf;
use Cro::WebApp::Template;

class Rakuwa::Layout {
    has $.template is rw = "layout.crotmp";

    method render ($view --> Str) {
        say "Rendering layout with template: ", $.template;
        say "Content: ", $view.content;
        say "Page title: ", $view.page<title>;
        say "Page description: ", $view.page<description>;
        say "Page keywords: ", $view.page<keywords>;
        say "Status: ", $view.status;
        template-location $conf<Template><template_dir>;
        return render-template $.template, {page => $view.page, content => $view.content};
    }

}
