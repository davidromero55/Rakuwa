use Rakuwa::Conf;
use Rakuwa::View;
use Rakuwa::Form;
use Rakuwa::DBTable;
use Rakuwa::DB;

class Rakuwa::Blog::AdminViews is Rakuwa::View {

    method display_home () {
        $.template    = 'user/display-home';
        %.page<title> = 'My Account';
        my $db = get-db;
        %.data<user> = $db.query("SELECT * FROM users WHERE user_id = ?", $.session.user-id).hash;
    }

    method display_categories () {
        my $table = Rakuwa::DBTable.new(
                :title('Categories'),
                :request($.request),
                :path(@.path),
                :name('login-form'),
                :key_column('category_id'),
                :query({
                    :select("*"),
                    :from("blog_categories"),
                    :order_by("category"),
                }),
                :columns-align(<left right center>),
                );
        $table.init;
        $table.render;
        $.status = $table.status;
        $.content = $table.content;

    }
}
