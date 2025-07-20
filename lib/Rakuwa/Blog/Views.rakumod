use Rakuwa::Conf;
use Rakuwa::View;
use Rakuwa::Form;
use Rakuwa::DB;

class Rakuwa::Blog::Views is Rakuwa::View {

    method display_home () {
        $.template    = 'user/display-home';
        %.page<title> = 'My Account';
        my $db = get-db;
        %.data<user> = $db.query("SELECT * FROM users WHERE user_id = ?", $.session.user-id).hash;
    }
}
