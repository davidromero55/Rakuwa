use Rakuwa;
use Rakuwa::Conf;
use Crust::Request;

class Rakuwa::File does Rakuwa::Conf {
    has Rakuwa $.rakuwa;

    method process () returns Str {
        # File exist
        my Str $file_name = $.conf{'App'}{'HomeDir'} ~ $.rakuwa.request.path-info;
        if "$file_name".IO.e {
            if "$file_name".IO.f {
                $.rakuwa.headers{'Content-Type'} = self.get_mime($.rakuwa.request.path-info);
                return (slurp "$file_name");
            }else{
                $.rakuwa.status = 404;
                return "File not found. " ~ $.rakuwa.request.path-info;
            }
        } else {
            $.rakuwa.status = 404;
            return "File not found. " ~ $.rakuwa.request.path-info;
        }
        return 'Rakuwa::    File';

#        return $.conf{'App'}{'HomeDir'};
#        return $.request.env{'PATH_INFO'};
    }

    method get_mime (Str $file_name) returns Str {
        my $ext = $file_name;
        $ext ~~ s:g/.+\.//;
        my %types = (
            'txt'  => 'text/plain',
            'html' => 'text/html',
            'htm'  => 'text/html',
            'css'  => 'text/css',
            'js'   => 'text/javascript',
            'gif'  => 'image/gif',
            'png'  => 'image/png',
            'jpg'  => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'bmp'  => 'image/bmp',
            'mdi'  => 'audio/midi',
            'wav'  => 'audio/wav',
            'xml'  => 'application/xml',
            'pdf'  => 'application/pdf',
        );
        my $mime = %types{$ext.lc};
        return 'text/plain' if $mime.codes == 0;
        return $mime;
    }
}
