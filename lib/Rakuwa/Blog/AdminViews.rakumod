use Rakuwa::Conf;
use Rakuwa::View;
use Rakuwa::Form;
use Rakuwa::DBTable;
use Rakuwa::DB;

class Rakuwa::Blog::AdminViews is Rakuwa::View {

    method display_home () {
        $.template    = 'user/display-home';
        %.page<title> = 'My Account';
        %.data<user> = $.db.query("SELECT * FROM users WHERE user_id = ?", $.session.user-id).hash;
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
        self.add-button('Add Category','/blog-admin/category', :icon('add'));
    }

    method display_category () {
        %.page<title> = 'Category Details';
        self.add-button('Back', '/blog-admin/categories', :icon('arrow_back'));

        my @submits = ('Save');
        my $category_id = 0;
        $category_id = Int(@.path[1]) if @.path[1];
        my %category;
        if $category_id > 0 {
            %category = $.db.query("SELECT * FROM blog_categories WHERE category_id = ?", $category_id).hash;
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
        if (%category<category_id>:exists) {
            $form.submit('Delete', {:class('btn btn-sm btn-danger')});
        }
        $form.render;
        $.status = $form.status;
        $.content = $form.content;
    }

    method display_authors () {
        my $table = Rakuwa::DBTable.new(
                :title('Blog Authors'),
                :request($.request),
                :path(@.path),
                :key_column('author_id'),
                :query({
                    :select("author_id, photo, name, email, url, entries"),
                    :from("blog_authors"),
                    :order_by("name"),
                }),
                :links({
                    :location('/blog-admin/author'),
                }),
                :columns-align(<center left left left right>),
                );
        $table.init;
        $table.get-data;
        for $table.data -> %row {
            if (%row<photo>:exists && %row<photo> ne '') {
                %row<photo> = self._tag('img', {
                    :src("/data/blog-authors/" ~ %row<photo>), :class('img-thumbnail'),
                    :style('width: 50px; height: 50px;'),
                    :alt(%row<name> // 'Author Photo'),
                    :title(%row<name> // 'Author Photo')
                });
            } else {
                %row<photo> = self._tag('img', {
                        :src("/assets/img/rakuwa64.png"), :class('img-thumbnail'),
                        :style('width: 50px; height: 50px;'),
                        :alt('Default Author Photo'),
                        :title('Default Author Photo')
                });
            }
        }

        $table.render;
        $.status = $table.status;
        $.content = $table.content;
        %.page<title> = 'Blog Authors';
        %.page<description> = 'Manage blog Authors';
        self.add-button('Add Author','/blog-admin/author',:icon('add'));
    }

    method display_author () {
        %.page<title> = 'Author Details';
        self.add-button('Back', '/blog-admin/authors', :icon('arrow_back'));

        my @submits = ('Save');
        my $author_id = 0;
        $author_id = Int(@.path[1]) if @.path[1];
        my %author;
        if $author_id > 0 {
            %author = $.db.query("SELECT * FROM blog_authors WHERE author_id = ?", $author_id).hash;
            @submits.push('Delete');
        }

        my $form = Rakuwa::Form.new(
                :request($.request),
                :path(@.path),
                :name('author-form'),
                :action('/blog-admin/author'),
                :method('POST'),
                :fields-names(["author_id", "name", "email", "photo", "about"]),
                :submits-names(@submits),
                :values(%author),
                );
        $form.init;
        $form.field('author_id', {:type('hidden')});
        $form.field('name', {:type('text'), :placeholder('Author Name'), :required, :help('Enter the author name')});
        $form.field('email', {:type('email'), :placeholder('Email'), :help('Enter the author email')});
        $form.field('photo', {:type('file'), :placeholder('Author Photo'), :help('Select an image file for the author photo, or leave empty to keep the current photo')});
        $form.field('about', {:type('textarea'), :placeholder('About Author'), :help('Enter a short description about the author')});


        if (%author<author_id>:exists) {
            $form.submit('Delete', {:class('btn btn-sm btn-danger')});
        }
        $form.render;
        $.status = $form.status;
        $.content = $form.content;
    }


}
