use Rakuwa::Conf;

class Rakuwa::Action {
    has Str $.status is rw = 'none';
    has Str $.redirect is rw = '';
    has %.headers is rw;
    has %.data is rw = {
        :msg(''),
    };
    has @.path is rw = ();
    has $.request is rw;
}
