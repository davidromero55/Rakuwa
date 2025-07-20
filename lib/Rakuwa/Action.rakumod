use Rakuwa::Conf;
use Rakuwa::DB;
use Rakuwa::SessionObject;

class Rakuwa::Action {
    has Str $.status is rw = 'none';
    has Str $.redirect is rw = '';
    has %.headers is rw;
    has %.data is rw = {
        :msg(''),
    };
    has @.path is rw = ();
    has $.request is rw;
    has $.db is rw = get-db();
    has Rakuwa::SessionObject $.session is rw = $!request.auth; # Session object from the request

    method add-msg(Str $type, Str $message, :$element = '') {
        $!request.auth.add-msg($type,$message, :$element);
    }

    method get-msgs(--> Array) {
        return $!request.auth.get-msgs;
    }

    method save-image ($image, Str $directory = '' --> Str) {
        my $filename = $image.filename;

        if $filename.chars == 0 {
            return "";  # Return empty string if the filename is invalid
        }

        my $extension = "$filename".IO.extension;
        my $type = $image.content-type.type;

        if ($type !~~ /image/) {
            say "Invalid image type: ", $type;
            return "";  # Return empty string if the type is not an image
        }

        # remove all to the right of the first dot
        $filename = $filename.subst(/<-[.]>+$/, '', :g);
        # Remove non-alphanumeric characters from the filename
        $filename = $filename.subst(/<-[\w\-]>/, '-', :g);
        $filename = "$filename.$extension";  # Add the extension back to the filename

        # Create the data directory if it doesn't exist
        if (! (%conf<data_directory>.IO ~~ :d)) {
            %conf<data_directory>.IO.mkdir;
        }

        # Create the directory for the image if specified
        my $filepath = %conf<data_directory>;
        $filepath = $filepath ~ $directory ~ '/' if $directory;
        if (! ($filepath.IO ~~ :d)) {
            $filepath.IO.mkdir;
        }

        # check write permissions
        if (! ($filepath.IO ~~ :w)) {
            say "Cannot write to directory: ", $filepath;
            return "";
        }

        # Add the image filename to the path
        $filepath = $filepath;  # Add the image filename to the path

        # Check if the file already exists
        if ("$filepath$filename".IO ~~ :f) {
            # try adding a timestamp to the filename
            my $timestamp = DateTime.now().posix;
            $filename = $filename.subst(/(\.\w+)$/, "-$timestamp.$extension");

            # Check if the new file already exists
            if ("$filepath$filename".IO ~~ :f) {
                say "File already exists with new name: ", $filepath;
                return "";  # Return empty string if the file already exists
            }
        }

        "$filepath$filename".IO.spurt: $image.body-blob;

        return $filename;
    }

    method url-safe-string(Str $orig-string --> Str) {
        # Convert the string to lowercase and trim whitespace
        my $string = $orig-string.trim.lc;

        # Replace non-alphanumeric characters with hyphens
        $string ~~ s:g/<-[ a..z|0..9 ]>/-/;

        # Remove consecutive hyphens
        $string ~~ s:g/ \-\-+ /-/;

        # Remove leading and trailing hyphens
        $string ~~ s:g/^\-//;
        $string ~~ s:g/\-$//;

        return $string;
    }
}
