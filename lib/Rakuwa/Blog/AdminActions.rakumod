use Rakuwa::Conf;
use Rakuwa::Action;
use Rakuwa::DB;

use Digest::SHA256::Native;

class Rakuwa::Blog::AdminActions is Rakuwa::Action {
    method do_category (%params) {
        my $submit = %params<_submit> // '';
        my $category_id = %params<category_id> // 0;
        my $category = %params<category> // '';
        my $url = self.url-safe-string($category);
        my $db = get-db;
        if ($submit eq 'Save') {
            if $category_id == 0 {
                # Create new category
                $db.query("INSERT INTO blog_categories (category, url) VALUES (?,?)", $category,
                $url);
                $.session.add-msg('success', "Category '$category' created successfully.");
            } else {
                # Update existing category
                $db.query("UPDATE blog_categories SET category = ?, url = ? WHERE category_id = ?",
                $category, $url, $category_id);
                $.session.add-msg('success', "Category updated successfully.");
            }
        } else {
            if $category_id > 0 {
                # Delete category
                $db.query("DELETE FROM blog_categories WHERE category_id = ?", $category_id);
                $.session.add-msg('success', "Category '$category' deleted successfully.");
            } else {
                $.session.add-msg('error', "No category selected for deletion.");
            }
        }
        $.redirect = '/blog-admin/categories';
    }

}
