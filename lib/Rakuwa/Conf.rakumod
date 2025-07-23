unit module Rakuwa::Conf;

our %conf is export = (
    :name('Rakuwa'),
    :version('0.1'),
    :description('Raku Web Application Framework'),
    :domain('localhost'),

    :port(5000),
    :debug,
    :timezone('America/Mexico_City'),
    :data_directory('lib/data/'),

    :db({
        :host('localhost'),
        :port(3306),
        :user('rakuwa'),
        :password('my-strong-password'),
        :database('rakuwa'),
        :charset('utf8mb4'),
    }),

    :session({
        :name('RAKUWA_SESSION'),
        :max_age(3600),
        :!secure,
        :httponly,
        :path('/'),
    }),

    :template({
        :template_dir('lib/templates'),
        :cache,
        :auto_reload,
    }),

    :security({
        :secret_key('tu-clave-secreta-muy-larga-y-segura'),
        :csrf_token('your-csrf-token'),
        :password_min_length(8),
    }),
);