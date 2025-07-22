use Rakuwa::Conf;
use Rakuwa::Action;
use Rakuwa::DB;

use Digest::SHA256::Native;

class Rakuwa::Blog::AdminActions is Rakuwa::Action {

    method do_category () {
        if (! self.validate-csrf(%.params<_csrf>)) {
            $.status = 'error';
            self.add-msg('warning', "Invalid CSRF token.");
            return;
        }

        my $submit = %.params<_submit> // '';
        my $category_id = %.params<category_id> // 0;
        my $category = %.params<category> // '';
        my $url = self.url-safe-string($category);
        if ($submit eq 'Save') {
            if $category_id == 0 {
                # Create new category
                $.db.query("INSERT INTO blog_categories (category, url) VALUES (?,?)", $category,
                $url);
                $.session.add-msg('success', "Category '$category' created successfully.");
            } else {
                # Update existing category
                $.db.query("UPDATE blog_categories SET category = ?, url = ? WHERE category_id = ?",
                $category, $url, $category_id);
                $.session.add-msg('success', "Category updated successfully.");
            }
        } else {
            if $category_id > 0 {
                # Delete category
                $.db.query("DELETE FROM blog_categories WHERE category_id = ?", $category_id);
                $.session.add-msg('success', "Category '$category' deleted successfully.");
            } else {
                $.session.add-msg('error', "No category selected for deletion.");
            }
        }
        $.redirect = '/blog-admin/categories';
    }

    method do_author () {
        my $file_name = self.save-image(%.params-files<photo>,'blog-authors');
        if (! self.validate-csrf(%.params<_csrf>)) {
            $.status = 'error';
            self.add-msg('warning', "Invalid CSRF token.");
            return;
        }

        my $submit = %.params<_submit> // '';
        my $author_id = %.params<author_id> // 0;
        my $name = %.params<name> // '';
        my $url = self.url-safe-string($name);
        if ($submit eq 'Save') {
            if $author_id == 0 {
                $.db.query("INSERT INTO blog_authors (name, email, photo, about, url) VALUES (?,?,?,?,?)",
                        $name, %.params<email>, $file_name, %.params<about>, $url);
                $.session.add-msg('success', "Author '$name' created successfully.");
            } else {
                $.db.query("UPDATE blog_authors SET name=?, email=?, about=?, url=? WHERE author_id = ?",
                        $name, %.params<email>, %.params<about>, $url, $author_id);

                if $file_name.chars > 0 {
                    $.db.query("UPDATE blog_authors SET photo = ? WHERE author_id = ?", $file_name, $author_id);
                }
                $.session.add-msg('success', "Category updated successfully.");
            }
        } else {
            if $author_id > 0 {
                $.db.query("DELETE FROM blog_authors WHERE author_id = ?", $author_id);
                $.session.add-msg('success', "Author '$name' deleted successfully.");
            } else {
                $.session.add-msg('error', "No category selected for deletion.");
            }
        }
        $.redirect = '/blog-admin/authors';
    }
}
