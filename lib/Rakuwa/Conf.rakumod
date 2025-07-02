

class Rakuwa::Conf {

    my %conf;

    has Str $.name is rw = 'Rakuwa';
    has Str $.version is rw = '0.1';
    has Str $.description is rw = 'Raku Web Application Framework';
    has Str $.domain is rw = 'localhost';

    has Int $.port is rw = 5000;
    has Bool $.debug is rw = True;
    has Str $.timezone is rw = 'America/Mexico_City';

    has Str $.secret_key is rw = 'tu-clave-secreta-muy-larga-y-segura';
    has Str $.csrf_token is rw = '';

    %conf<DB> = {
        :host('localhost'),
        :port(3306),
        :user('rakuwa'),
        :password('my-strong-password'),
        :database('rakuwa'),
        :charset('utf8'),
    };

    # Session
    %conf<Session> = {
        :name('RAKUWA_SESSION'),
        :max_age(3600),
        :!secure,
        :httponly,
        :path('/'),
    };

    # Templates
    %conf<Template> = {
        :template_dir('lib/templates/main'),
        :cache,
        :auto_reload,
    };

    # Security
    %conf<Security> = {
        :secret_key('tu-clave-secreta-muy-larga-y-segura'),
        :csrf_token,
        :password_min_length(8),
    };

    method get (Str $key --> Any) {
        return %conf{$key} if %conf{$key}.defined;
        return Nil;
    }

    method get-all (--> Hash) {
        return %conf;
    }

}



