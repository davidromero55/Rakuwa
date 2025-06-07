unit package Rakuwa::Conf;

# Export $conf var
our $conf is export = {};

# Database
$conf<DB> = {
    :host('localhost'),
    :port(3306),
    :user('rakuwa_user'),
    :password('rakuwa_pass'),
    :database('rakuwa_db'),
    :charset('utf8mb4'),
};

# Application
$conf<App> = {
    :name('Rakuwa'),
    :description('Raku Web Application Framework'),
    :version('0.1'),
    :domain('localhost'),
    :port(5000),
    :debug,
    :timezone('America/Mexico_City'),
};

# Session
$conf<Session> = {
    :name('RAKUWA_SESSION'),
    :max_age(86400),  # 24 hours
    :!secure,
    :httponly,
    :path('/'),
};

# Templates
$conf<Template> = {
    :template_dir('lib/templates/main'),
    :cache,
    :auto_reload,
};

# Security
$conf<Security> = {
    :secret_key('tu-clave-secreta-muy-larga-y-segura'),
    :csrf_token,
    :password_min_length(8),
};

