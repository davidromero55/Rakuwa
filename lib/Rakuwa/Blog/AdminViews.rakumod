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
                :title('Blog Categories'),
                :request($.request),
                :path(@.path),
                :name('login-form'),
                :key_column('category_id'),
                :query({
                    :select("category_id, category, url, entries"),
                    :from("blog_categories"),
                    :order_by("category"),
                }),
                :links({
                    :location('/blog-admin/category'),
                }),
                :columns-align(<left left right>),
                );
        $table.init;
        $table.render;
        $.status = $table.status;
        $.content = $table.content;
        %.page<title> = 'Blog Categories';
        %.page<description> = 'Manage blog categories';
        self.add-button('Add Category','/blog-admin/category');
    }

    method display_category () {
        %.page<title> = 'Category Details';
        self.add-button('Back', '/blog-admin/categories');

        my @submits = ('Save');
        my $category_id = Int(@.path[1]) // 0;
        my $db = get-db;
        my %category;
        if $category_id > 0 {
            %category = $db.query("SELECT * FROM blog_categories WHERE category_id = ?", $category_id).hash;
            @submits.push('Delete');
        }


        my $form = Rakuwa::Form.new(
                :request($.request),
                :path(@.path),
                :name('category-form'),
                :action('/blog-admin/category'),
                :method('POST'),
                :fields-names(["category_id", "category"]),
                :submits-names(@submits),
                :values(%category),
                );
        $form.init;
        $form.field('category_id', {:type('hidden')});
        $form.field('category', {:type('text'), :placeholder('Category Name'), :required, :help('Enter the category name')});
        if (%category<category_id> > 0) {
            $form.submit('Delete', {:class('btn btn-sm btn-danger')});
        }
        $form.render;
        $.status = $form.status;
        $.content = $form.content;
    }

}
