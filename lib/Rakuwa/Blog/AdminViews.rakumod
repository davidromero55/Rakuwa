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
                    :limit(30),
                }),
                :links({
                    :location('/blog-admin/author'),
                }),
                :columns-align(<center left left left right>),
                );
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

        $table.set-column-label('name', 'Author Name');
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

    method display_entries () {
        my $table = Rakuwa::DBTable.new(
                :title('Blog entries'),
                :request($.request),
                :path(@.path),
                :key_column('entry_id'),
                :query({
                    :select("e.entry_id, e.date, e.title, a.name AS author, e.publish, e.url AS actions"),
                    :from("blog_entries e LEFT JOIN blog_authors a ON e.author_id = a.author_id"),
                    :order_by("date DESC"),
                    :limit(30),
                }),
                :columns-align(<center left left center center>),
                );
        $table.get-data;
        for $table.data -> %row {
            %row<actions> = self._tag('a', {
                :href("/blog-admin/entry/" ~ %row<entry_id>),
                :class('btn btn-sm btn-secondary'),
                :title('Edit Entry'),
                :style('margin-right: 5px;')
            }, self._tag('span', {:class('material-symbols-outlined')}, 'edit'))
            ~ self._tag('a', {
                :href("/blog/" ~ %row<actions>),
                :class('btn btn-sm btn-secondary'),
                :title('View Entry'),
                :target('_blank'),
            }, self._tag('span', {:class('material-symbols-outlined')}, 'open_in_new')) ;

            if (%row<publish> eq 1) {
                %row<publish> = 'Yes';
            } else {
                %row<publish> = 'No';
            }
        }

        $table.render;
        $.status = $table.status;
        $.content = $table.content;
        %.page<title> = 'Blog Entries';
        %.page<description> = 'Manage blog Entries';
        self.add-button('Add Entry','/blog-admin/entry',:icon('add'));
    }

    method display_entry () {
        %.page<title> = 'Blog Entry';
        self.add-button('Back', '/blog-admin/entries', :icon('arrow_back'));

        my @submits = ('Save');
        my $entry_id = 0;
        $entry_id = Int(@.path[1]) if @.path[1];
        my %entry;
        if $entry_id > 0 {
            %entry = $.db.query("SELECT * FROM blog_entries WHERE entry_id = ?", $entry_id).hash;
            @submits.push('Delete');
        }

        my $form = Rakuwa::Form.new(
                :request($.request),
                :path(@.path),
                :name('entry-form'),
                :action('/blog-admin/entry'),
                :method('POST'),
                :fields-names(["entry_id", 'title', 'description', 'content', 'publish', 'author_id', 'date', 'keywords', 'image']),
                :submits-names(@submits),
                :values(%entry),
                :template('blog/entry-form'),
                );
        $form.init;
        $form.field('entry_id', {:type('hidden')});
        $form.field('title', {:type('text'), :placeholder('Entry Title'), :required, :help('Enter the entry title')});
        $form.field('description', {:type('textarea'), :placeholder('Entry Description'), :required, :help('Enter a short description of the entry')});
        $form.field('content', {:type('textarea'), :placeholder('Entry Content'), :required, :help('Enter the entry content'), :rows(20)});
        $form.field('publish', {:type('checkbox'), :label('Publish'), :role("switch"),:help('Check to publish the entry immediately')});
        my %authors-sd = self.get-selectbox-data("SELECT author_id, name FROM blog_authors ORDER BY name");
        $form.field('author_id', {
            :type('select'),
            :label('Author'),
            :options(%authors-sd<options>),
            :labels(%authors-sd<labels>),
            :selectname('Select the author of the entry')
        });

        $form.field('date', {:type('date'), :disabled , :help('Enter the date and time of the entry')});
        $form.field('keywords', {:type('textarea'), :placeholder('Keywords'), :help('Enter keywords for the entry, separated by commas'), :rows(3)});
        $form.field('image', {:type('file'), :placeholder('Entry Image'), :help('Select an image file for the entry, or leave empty to keep the current image')});

        if (%entry<entry_id>:exists) {
            $form.submit('Delete', {:class('btn btn-sm btn-danger')});
        }
        $form.render;
        $.status = $form.status;
        $.content = $form.content;
    }


}
