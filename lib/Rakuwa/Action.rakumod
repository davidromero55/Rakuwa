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
    has %.params is rw = {};
    has %.params-files is rw = {};
    has $.db is rw = get-db();
    has Rakuwa::SessionObject $.session is rw;

    submethod BUILD(:$request, :@path, :%params) {
        $!request = $request;
        @!path = @path;
        $!session = $!request.auth;  # Initialize session object

        if %params.elems > 0 {
            for %params.kv -> $key, $value {
                given $value.^name {
                    when 'Cro::HTTP::Body::MultiPartFormData::Part' {
                        if $value.filename:exists {
                            #say "File: $key, Filename: " ~ $value.filename;
                            %!params-files{$key} = $value;
                        } else {
                            #say "Param: $key, Value: " ~ $value.body-blob.decode('utf-8');
                            %!params{$key} = $value.body-blob.decode('utf-8');
                        }
                    }
                    default {
                        # say "Def Param: $key, Value: " ~ $value;
                        %!params{$key} = $value;  # Keep the value as is
                    }
                }
            }
        }
    }

    method add-msg(Str $type, Str $message, :$element = '') {
        $!request.auth.add-msg($type,$message, :$element);
    }

    method get-msgs(--> Array) {
        return $!request.auth.get-msgs;
    }

    method save-image ($image, Str $directory = '' --> Str) {
        if (! $image.can('filename')) {
            return "";  # Return empty string if the image object is invalid
        }

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

    method exists (--> Bool) {
        if (self.can("{self.get-action-function-name}")) {
                return True;
        }
        return False;
    }

    method execute() {
        # Execute the action function if it exists
        my $action-function = self.get-action-function-name;
        self."$action-function"();
        self.free;
    }

    method get-action-function-name ( --> Str) {
        # Get the view function name from the path
        my $ViewName = "do_home";
        with @.path[0] {
            $ViewName = "do_" ~ @.path[0].lc;
            $ViewName ~~ s:g/\W//; # Sanitize the function name
        }
        return $ViewName;
    }

    method validate-csrf(Str $token --> Bool) {
        # Validate the CSRF token
        if $token eq $!session.csrf-token {
            return True;
        } else {
            self.add-msg('error', 'Invalid CSRF token.');
            return False;
        }
    }

    method free {
        # Finalize the view, clean up resources if needed
        $!db.finish;
    }

}
