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
    has %.conf is rw = Rakuwa::Conf.new().get-all();
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
        my $extension = "$filename".IO.extension;
        my $type = $image.content-type.type;

        if $filename.chars == 0 {
            say "Invalid filename: ", $image.filename;
            return "";  # Return empty string if the filename is invalid
        }

        if ($type !~~ /image/) {
            say "Invalid image type: ", $type;
            return "";  # Return empty string if the type is not an image
        }

        my $conf = Rakuwa::Conf.new;

        # remove all to the right of the first dot
        $filename = $filename.subst(/<-[.]>+$/, '', :g);
        # Remove non-alphanumeric characters from the filename
        $filename = $filename.subst(/<-[\w\-]>/, '-', :g);
        $filename = "$filename.$extension";  # Add the extension back to the filename

        # Create the data directory if it doesn't exist
        if (! ($conf.data_directory.IO ~~ :d)) {
            $conf.data_directory.IO.mkdir;
        }

        say "Saving image to: ", $conf.data_directory;

        # Create the directory for the image if specified
        my $filepath = $conf.data_directory;
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

        say "Full file path: ", $filepath;

        # Check if the file already exists
        if ("$filepath$filename".IO ~~ :f) {
            say "File already exists: ", $filepath , $filename;

            # try adding a timestamp to the filename
            my $timestamp = DateTime.now().posix;
            $filename = $image.filename.subst(/(\.\w+)$/, "-$timestamp.$extension");

            # Check if the new file already exists
            if ("$filepath$filename".IO ~~ :f) {
                say "File already exists with new name: ", $filepath;
                return "";  # Return empty string if the file already exists
            }
        }

        say "Saving image to: ", $filepath, $filename;
        # write the image to the file
        "$filepath$filename".IO.spurt: $image.body-blob;

        return $filename;
    }
}
