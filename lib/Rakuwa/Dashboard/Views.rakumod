use Rakuwa::Conf;
use Rakuwa::View;
use Rakuwa::Form;
use Rakuwa::DB;

class Rakuwa::Dashboard::Views is Rakuwa::View {

    method display_home () {
        say "Displaying Dashboard Home";
        self.template = 'dashboard/display-home';
        %.page<title> = 'Dashboard Home';
    }

}
