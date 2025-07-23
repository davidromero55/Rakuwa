use Rakuwa::Conf;
use Rakuwa::View;
use Rakuwa::Form;
use Rakuwa::DB;

class Rakuwa::Blog::Views is Rakuwa::View {

    method display_home () {
        $.template    = 'blog/display-home';
        %.data<entries> = $.db.query(
            "SELECT e.title, e.description, e.url, DATE_FORMAT(e.date,'%M %d, %Y') AS date, e.image, a.name AS author_name, a.photo AS author_photo "
            ~ "FROM blog_entries e "
            ~ "LEFT JOIN blog_authors a ON e.author_id = a.author_id "
            ~ "WHERE e.publish = 1 "
            ~ "ORDER BY date DESC LIMIT 20").hashes;
        #for %.data<entries> -> %entry {
        #}
    }

    method display_entry () {
        my $entry_url = @.path[1] // '';
        say "Entry URL: $entry_url"; # Debugging line
        my %entry = $.db.query("SELECT * FROM blog_entries WHERE url = ?", $entry_url).hash;

        # Decode the entry fields if they are in bytes
        # Todo: Manage encoding from db module
        %entry<content> = %entry<content>.decode('utf-8');
        %entry<content> = %entry<content>.subst("\n", "<br>", :g);

        %.data<entry> = %entry;
        %.page<title> = %entry<title> // 'Blog Entry';
        %.page<description> = %entry<description> // '';
        %.page<keywords> = %entry<keywords> // '';
        if %entry {
            $.template = 'blog/display-entry';
        } else {
            $.status = 404;
            $.content = "Blog entry not found.";
        }
    }
}
