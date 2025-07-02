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
}
